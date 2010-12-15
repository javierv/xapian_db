# encoding: utf-8

module XapianDb
  module Adapters

    # base class for all adapters.
    # This adapter does the following:
    # - adds the class method <code>search(expression)</code> to an indexed class
    # @author Gernot Kogler

     class BaseAdapter

       class << self

         # Implement the class helper methods
         # @param [Class] klass The class to add the helper methods to
         def add_class_helper_methods_to(klass)

           klass.class_eval do

             # Add a method to search models of this class
             # Options:
             # - :order          (Array<Symbol>) Accepts an array of attribute names for sorting
             # - :sort_decending (Boolean)       Allows to reverse the sorting
             define_singleton_method(:search) do |expression, options={}|
               options = {:sort_decending => false}.merge options
               class_scope = "indexed_class:#{klass.name.downcase}"

               if options[:order]
                 attr_names   = [options[:order]].flatten
                 sort_indices = []
                 blueprint    = XapianDb::DocumentBlueprint.blueprint_for klass
                 attr_names.each do |attr_name|
                   attr_index = blueprint.attributes_hash.keys.sort.index(attr_name.to_sym)
                   raise ArgumentError.new("Unknown attribute name #{attr_name} in order clause") if attr_index.nil?
                   # We have to add 1 to the position of the index since value slot 0 is reserved for the class name
                   sort_indices << attr_index + 1
                 end
               else
                 sort_indices = nil
               end
               result = XapianDb.database.search "#{class_scope} and (#{expression})", :sort_indices => sort_indices, :sort_decending => options[:sort_decending]

               # Remove the class scope from the spelling suggestion (if any)
               unless result.spelling_suggestion.empty?
                 scope_length = "#{class_scope} and (".size
                 result.spelling_suggestion = result.spelling_suggestion.slice scope_length..-2
               end
               result
             end

           end
         end
       end
     end
   end
 end
