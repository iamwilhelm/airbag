#!/usr/bin/ruby

$LOAD_PATH << File.dirname(__FILE__)
require "span"
require "merge"
require "squash"

# DataFile manages an input text file.  it keeps track of which lines have been dropped.

class DataFile
  include Merge
  include Squash

  attr_reader :droppedlines
  attr_reader :content
  attr_reader :fulllength

  def initialize(fname)
    @fname = fname
    @droppedlines = []
    File.open fname do |fin|
      @content = fin.readlines
    end
    @fulllength = @content.length
    # remove whitespace at line start/end
    @content.each { |ll| ll.strip! }
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

  # apply block to each col in span to the specified line, skipping dropped lines
  # assumes datafile is csv format
  def each_col_in_span(linenum, spanstr)
    span = Span.new(spanstr, nil)
    fields = @content[shiftedindex linenum].split ","
    span.each { |colnum| yield fields[colnum] }
  end

  # linenums is the span of lines to remove (inclusive, indexed from 1)
  # linenums index into the original datafile
  def droplines(linenums)
    span = Span.new(linenums, @fulllength)
    span.each { |linenum|
      if !@droppedlines.include? linenum
        @content.delete_at(shiftedindex linenum)
        @droppedlines.push linenum
      end
    }
  end

  # drop lines not containing the given string
  def droplines_without(linenums, str)
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
  def droplines_containing(linenums, str)
    span = Span.new(linenums, @fulllength)
    span.each { |linenum|
      if !@droppedlines.include? linenum and
          @content[shiftedindex linenum].include? str
        @content.delete_at(shiftedindex linenum)
        @droppedlines.push linenum
      end
    }
  end

  # stack the specified rows to the right of line index
  def stack(linenums, index)
    linenum_indices = Span.new(linenums, @fulllength).to_a
    first = linenum_indices[0]
    for linenum in linenum_indices do
      @content[shiftedindex(index.to_i + linenum - first)] +=
        "," + @content[shiftedindex linenum]
    end
    droplines linenums
  end

  # concatenate a table to the end of another
  def concat(other)
    @content += other.content
    @droppedlines += other.droppedlines.map{ |x| x + @fulllength }
    @fulllength += other.fulllength
  end

  # merge table2 into table1
  def merge(tables, indcols)
    @content = merge_tables([@content] + tables, indcols)
    @fulllength = @content.length
    @droppedlines = []
  end

  # squash table
  def squash(indcols, new_indvar_names)
    @content = squash_table(@content, indcols, new_indvar_names)
    @fulllength = @content.length
    @droppedlines = []
  end

  private

  # shift given index by the number of dropped lines above it
  def shiftedindex(linenum)
    shift = @droppedlines.select { |nn| nn < linenum }.length
    linenum - shift - 1
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
