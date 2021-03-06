# encoding: utf-8

# Basic mocks for our tests
# @author Gernot Kogler

# Test class for indexed objects
class IndexedObject
  
  attr_reader :id
  
  def initialize(id)
    @id = id
  end
  
end

# Test adapter 
class DemoAdapter

  def self.add_class_helper_methods_to(klass)

    klass.instance_eval do
      
      # This method must be implemented by all adapters. It must
      # return a string that uniquely identifies an object
      define_method(:xapian_id) do
        "a_unique_key_expression"
      end
    end

  end
  
  def self.add_doc_helper_methods_to(klass)
  end
  
end

