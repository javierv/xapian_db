# encoding: utf-8

# Mocks for the orm adapter tests
# @author Gernot Kogler

class PersistentObject

  @objects = []

  class << self

    attr_reader :hooks

    def reset
      @objects = []
      @hooks = {}
    end

    def count
      @objects.size
    end

    def all(options={})
      @objects
    end

  end

  attr_reader :id, :name

  def initialize(id, name)
    @id, @name = id, name
  end

  def save
    self.class.all << self
    instance_eval &self.class.hooks[:after_save] if self.class.hooks[:after_save]
  end

  def destroy
    self.class.all.delete self
    instance_eval &self.class.hooks[:after_destroy]
  end

end

# Test class for indexed datamapper objects; this class mimics some behaviour
# of datamapper and has methods to test the helper methods
class DatamapperObject < PersistentObject

  class << self

    def get(id)
      @objects.detect{|o| o.id == id}
    end

    # Simulate the after method of datamapper
    def after(action, &block)
      @hooks ||= {}
      @hooks["after_#{action}".to_sym] = block
    end

  end

end

# Test class for indexed active_record objects; this class mimics some behaviour
# of active_record and has methods to test the helper methods
class ActiveRecordObject < PersistentObject

  class << self

    def find(id)
      @objects.detect{|o| o.id == id}
    end

    # Simulate the after_save method of activerecord
    def after_save(&block)
      @hooks ||= {}
      @hooks["after_save".to_sym] = block
    end

    # Simulate the after_destroy method of activerecord
    def after_destroy(&block)
      @hooks ||= {}
      @hooks["after_destroy".to_sym] = block
    end

  end

end
