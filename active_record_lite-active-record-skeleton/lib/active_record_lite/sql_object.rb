require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'
require 'active_support/inflector'


class SQLObject < MassObject
  extend Searchable
  extend Associatable

  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name.underscore
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
    SELECT *
    FROM #{table_name}
    SQL
    parse_all(results)

  end

  def self.find(id)
    array = DBConnection.execute(<<-SQL)
    SELECT *
    FROM #{table_name}
    WHERE id = #{id}
    SQL
    parse_all(array)[0]
  end

  def save
    id.nil? ? create : update
  end

  private
  def create
    DBConnection.execute(<<-SQL, *attribute_value_array)
        INSERT INTO #{self.class.table_name.to_s}
                    (#{self.class.attributes.join(", ")})
        VALUES
                    (#{(["?"] * self.class.attributes.length).join(", ")})
        SQL
    array = DBConnection.execute(<<-SQL)
        SELECT MAX(id)
        FROM #{self.class.table_name}
        SQL
    id = array[0]["MAX(id)"]
  end

  def attribute_value_array
    self.class.attributes.map{|a| send(a) }
  end

  def update
    update_string = self.class.attributes.map{|a| a.to_s + " = ?"}.join(", ")
    DBConnection.execute(<<-SQL, *attribute_value_array)
    UPDATE  #{self.class.table_name}
    SET     #{update_string}
    WHERE   id = #{id}
    SQL
  end



end
