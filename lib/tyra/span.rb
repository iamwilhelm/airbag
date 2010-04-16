# iterate over the values defined by a string made up of items and
# ranges
class Span
  # str can be of the form "1-4,6,8,10-12"
  # or "*" for "1-end"
  # maxlen is the end value for *
  # segments is an array of ranges
  def initialize(str, maxlen)
    @segments =     
      if str.class == String
        str.split(",").map { |segment|
          if segment.include? "-"               # range
            Range.new( *segment.split("-").map{|x|
                         if x=="*"
                           maxlen
                         else
                           x.to_i
                         end
                       } )
          elsif segment == "*"                  # whole file
            1..maxlen
          else                                  # single index
            segment..segment
          end
        }
      else
        [str..str]
      end
  end

  # yield each value in the span
  def each()
    for segment in @segments do
      for val in segment do
        yield val.to_i
      end
    end
  end

  def to_a()
    ret = []
    for segment in @segments do
      ret += segment.to_a.map{ |val| val.to_i }
    end
    ret.sort
  end
end

#s = Span.new("1-4,6,9-11,13,15", nil)
#s.each() { |val| puts val }
#puts s.to_a.inspect
