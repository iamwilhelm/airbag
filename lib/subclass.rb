# includes ability for class to know about its subclasses
module Subclass
  def self.included(base)
    base.class_exec do
      class << base
        def inherited(other)
          super if defined? super
        ensure
          @subclasses ||= []
          @subclasses.push(other) unless @subclasses.include?(other)
        end

        def subclasses
          @subclasses ||= []
          @subclasses.inject([]) do |list, subclass|
            list.push(subclass, *subclass.subclasses)
          end
        end
      end
    end
  end
end

if __FILE__ == $0
  require 'pp'
  
  class A
    include Subclass
  end
  
  class B < A
  end

  class C < B
  end
  
  p A.subclasses
  p B.subclasses
end
