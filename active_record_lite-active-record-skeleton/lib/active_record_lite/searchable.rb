require_relative './db_connection'

module Searchable
  def where(params)
    attributes = params.keys.map { |k| k.to_s + " = ?"}.join(" AND ")
    attribute_values = params.keys.map { |k| params[k]}
    results = DBConnection.execute(<<-SQL, *attribute_values)
      SELECT *
      FROM #{table_name}
      WHERE #{attributes}
    SQL
    parse_all(results)
  end
end