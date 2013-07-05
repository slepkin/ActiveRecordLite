require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class
    given_cn = @params[:class_name]
    other_class_name = (given_cn ? given_cn : @name.to_s.singularize.camelize)
    other_class_name.constantize
  end

  def other_table
    other_class.table_name
  end

  def primary_key
    given_pk = @params[:primary_key]
    primary_key = (given_pk ? given_pk : :id)
  end

end

class BelongsToAssocParams < AssocParams
  def initialize(name, params)
    @name = name
    @params = params
  end

  def foreign_key
    given_fk = @params[:foreign_key]
    foreign_key = (given_fk ? given_fk : "#{@name}_id".to_sym)
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, my_class_name)
    @name = name
    @params = params
    @my_class_name =  my_class_name
  end

  def foreign_key
    given_fk = @params[:foreign_key]
    foreign_key = (given_fk ? given_fk : "#{@my_class_name.underscore}_id".to_sym)
  end

  def type
  end
end

module Associatable
  def assoc_params
    @assoc_params.nil? ? @assoc_params = {} : @assoc_params
  end

  def belongs_to(name, params = {})
    assoc_params[name] = BelongsToAssocParams.new(name, params)
    p "Associating #{self} to #{name}, with parameters:"
    p assoc_params[name]
    define_method(name) do
      aps = self.class.assoc_params[name]
      aps.other_class.find(self.send(aps.foreign_key))
    end
  end

  def has_many(name, params = {})
    define_method(name) do
      aps = HasManyAssocParams.new(name, params, self.class.to_s)
      aps.other_class.where({aps.foreign_key => self.send(aps.primary_key)})
    end
  end

  def has_one_through(name, assoc1, assoc2)
    my_table = table_name

    define_method(name) do
      aps1 = self.class.assoc_params[assoc1]
      p "aps1 stored ok"
      aps2 = aps1.other_class.assoc_params[assoc2]
      p aps1
      p aps2
      array = DBConnection.execute(<<-SQL)
        SELECT  #{aps2.other_table}.*
        FROM    #{my_table}
        JOIN    #{aps1.other_table}
        ON      #{my_table}.#{aps1.foreign_key}
                  = #{aps1.other_table}.#{aps1.primary_key}
        JOIN    #{aps2.other_table}
        ON      #{aps1.other_table}.#{aps2.foreign_key}
                  = #{aps2.other_table}.#{aps2.primary_key}
      SQL
      p "Query gave us:"
      p array
      aps2.other_class.new(array[0])
    end
  end
end
