#!/usr/bin/ruby

$LOAD_PATH << File.dirname(__FILE__)
require "span"
require "merge"
require "squash"

# DataFile manages an input text file.  it keeps track of which lines
# have been dropped.
class DataFile
  include Merge
  include Squash

  attr_reader :droppedlines
  attr_reader :content
  attr_reader :fulllength

  def initialize(fname = nil)
    @droppedlines = []
    @content = []
    if fname != nil
      @fname = fname
      File.open fname do |fin|
        @content = fin.readlines
      end
      # remove whitespace at line start/end
      @content.each { |ll| ll.strip! }
    end
    @fulllength = @content.length
  end

  # insert content from one table to another
  # content is an array of strings
  # insert_index is the point of insertion
  def insert_cmd(content, insert_index)
    #puts "inserting lines: " + content.inspect
    count = 0
    for line in content do
      @content.insert(insert_index - 1 + count, line)
      count += 1
    end
    @fulllength += count
    @droppedlines.map!{ |x| x += count if x > insert_index }
  end

  # apply block to each line in span, skipping dropped lines
  def each_line_in_span(spanstr)
    #puts @droppedlines.inspect
    span = Span.new(spanstr, @fulllength)
    span.each { |linenum|
      if !@droppedlines.include? linenum
        yield @content[shiftedindex linenum]
      end
    }
  end

  private

  # apply block to each col in span to the specified line, skipping dropped lines
  # assumes datafile is csv format
  def each_col_in_span(linenum, spanstr)
    span = Span.new(spanstr, nil)
    fields = @content[shiftedindex linenum].split ","
    span.each { |colnum| yield fields[colnum] }
  end

  # linenums is the span of lines to remove (inclusive, indexed from 1)
  # linenums index into the original datafile
  def droplines_cmd(linenums)
    #puts "dropping lines " + linenums.to_s
    span = Span.new(linenums, @fulllength)
    span.each { |linenum|
      if !@droppedlines.include? linenum
        @content.delete_at(shiftedindex linenum)
        @droppedlines.push linenum
      end
    }
  end

  # drop lines not containing the given string
  def droplines_without_cmd(linenums, str)
    #puts "dropping lines without " + str.to_s + " for lines " + linenums
    span = Span.new(linenums, @fulllength)
    span.each { |linenum|
      if !@droppedlines.include? linenum and
          !@content[shiftedindex linenum].include? str
        @content.delete_at(shiftedindex linenum)
        @droppedlines.push linenum
      end
    }
  end

  # drop lines containing the given string
  def droplines_containing_cmd(linenums, str)
    #puts "dropping lines containing " + str.to_s + " for lines " + linenums
    span = Span.new(linenums, @fulllength)
    span.each { |linenum|
      if !@droppedlines.include? linenum and
          @content[shiftedindex linenum].include? str
        @content.delete_at(shiftedindex linenum)
        @droppedlines.push linenum
      end
    }
  end

  # drop the specified column range from the specified rows
  def dropcols_cmd(linenums, colnums)
    #puts "dropping cols " + colnums.to_s + " from lines " + linenums.to_s
    colnums = Span.new(colnums, nil).to_a.reverse
    each_line_in_span(linenums) { |line|
      fields = line.split ","
      colnums.each { |colnum| fields.delete_at(colnum - 1) }
      line.replace(fields.join ",")
    }
  end

  # remove commas from inside quoted strings, and remove quotes
  # so '"1,200","2,300"' becomes '1200,2300'
  def strip_quotes_commas_cmd(linenums)
    #puts "stripping quotes and commas from lines " + linenums.to_s
    each_line_in_span(linenums) do |line|
      inquote = false;
      newLine = '';
      line.chars.each{ |char|
        if char == '"'
          inquote = !inquote
        else
          newLine += char if char != ',' || !inquote
        end
      }
      line.replace newLine
    end
  end

  # replace str1 with str2
  def replace_cmd(linenums, str1, str2)
    str1 = replaceparam str1
    str2 = replaceparam str2
    #puts "replacing \"" + str1.to_s + "\" with \"" + str2.to_s + "\" for lines " + linenums.to_s
    each_line_in_span(linenums) do |line|
      line.replace line.gsub(str1, str2)
    end
  end

  # stack the specified rows to the right of line index
  def stack_cmd(linenums, index)
    #puts "stacking " + linenums.to_s + " next to " + index.to_s
    linenum_indices = Span.new(linenums, @fulllength).to_a
    first = linenum_indices[0]
    for linenum in linenum_indices do
      @content[shiftedindex(index.to_i + linenum - first)] +=
        "," + @content[shiftedindex linenum]
    end
    droplines_cmd linenums
  end
  # prefix the specified lines with the given string
  def prefixlines_cmd(linenums, str)
    #puts "prefixing lines " + linenums.to_s + " with " + str.to_s
    each_line_in_span(linenums) do |line|
      line.replace(str.to_s + line)
    end
  end

  # suffix the specified lines with the given string
  def suffixlines_cmd(linenums, str)
    #puts "suffixing lines " + linenums.to_s + " with " + str.to_s
    each_line_in_span(linenums) do |line|
      line.replace(line + str.to_s)
    end
  end

  # scale values by given scale factor
  # datafile must be comma delimited
  # sf scale factor
  def scale_cmd(linenums, colnums, sf)
    #puts "scaling lines " + linenums.to_s + " cols " + colnums.to_s + " by " + sf.to_s
    each_line_in_span(linenums) do |line|
      fields = line.split ","
      colspan = Span.new(colnums, nil)
      colspan.each{ |colnum|
        fields[colnum] = (fields[colnum].to_f * sf.to_f).to_s
      }
      line.replace(fields.join ",")
    end
  end

  # replace state names with abbreviations
  def abbrev_cmd(linenums, fname)
    #puts "replacing states with abbrev"
    stateabbrev = []
    fname = File.join(File.dirname(__FILE__), fname + ".txt")
    File.open(fname, "r") do |fin|
      fin.each_line do |ll|
        stateabbrev.push to_fields(ll)
      end
    end
    each_line_in_span(linenums) do |line|
      # FIXME I think you can use gsub with /#{s_name}/m here.  
      stateabbrev.each { |s_abbr, s_name| line.sub!(/#{s_name}/, s_abbr) }
    end 
  end

  # copy content from one table to another
  # from tables[1] to tables[0]
  # insert_index is the point of insertion
  # copy_span are the lines being copied
  def copy_cmd(tables, insert_index, copy_span)
    #puts "copying lines " + copy_span.to_s + " at line " + insert_index.to_s
    count = 0
    tables[1].each_line_in_span(copy_span) do |line|
      @content.insert(insert_index - 1 + count, line)
      count += 1
    end
    @fulllength += count
    @droppedlines.map!{ |x| x += count if x > insert_index }
  end

  # concatenate a table to the end of another
  def concat_cmd(tables)
    #puts "concatinating tables"
    @content += tables[1].content
    @droppedlines += tables[1].droppedlines.map{ |x| x + @fulllength }
    @fulllength += tables[1].fulllength
  end

  # merge table2 into table1
  def merge_cmd(tables, indcols)
    #puts "merging tables"
    tables.map!{ |x| x.content }
    @content = merge_tables([@content] + tables, indcols)
    @fulllength = @content.length
    @droppedlines = []
  end

  # squash table
  def squash_cmd(indcols, new_indvar_names)
    #puts "squashing table"
    @content = squash_table(@content, indcols, new_indvar_names)
    @fulllength = @content.length
    @droppedlines = []
  end

  # write data to output file
  def write_cmd(fname)
    #puts "writing file " + fname
    File.open(fname, "w") do |fout|
      each_line_in_span("*") { |line|
        fout.write line + "\n"
      }
    end
  end

  # shift given index by the number of dropped lines above it
  def shiftedindex(linenum)
    shift = @droppedlines.select { |nn| nn < linenum }.length
    linenum - shift - 1
  end

  # remove quotes or build a regex to be passed into a gsub
  def replaceparam(str)
    if str[0,1] == "/"
      str = Regexp.new str[1..-2]
    else
      str
    end
  end
end

#df = DataFile.new("singles.csv")
#df.each_line_in_span("1-10") { |line| puts line[0..40] }
#puts "---"
#df.each_line_in_span("1-2,4,6") { |line| line.replace("_" + line) }
#df.droplines_cmd("3-5,7")
#df.droplines_without_cmd("3-5,7", ",Ariz")
#df.droplines_containing_cmd("3-5,7", ",Ariz")
#df.dropcols_cmd("3-5,7", "1-2,4")
#df.each_line_in_span("1-10") { |line| puts line[0..40] }
