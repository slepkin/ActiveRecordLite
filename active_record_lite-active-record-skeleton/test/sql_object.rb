require './lib/active_record_lite'

# https://tomafro.net/2010/01/tip-relative-paths-with-file-expand-path
cats_db_file_name =
  File.expand_path(File.join(File.dirname(__FILE__), "cats.db"))
DBConnection.open(cats_db_file_name)

class Cat < SQLObject
  set_table_name("cats")
  set_attrs(:id, :name, :owner_id)
end

class Human < SQLObject
  set_table_name("humans")
  set_attrs(:id, :fname, :lname, :house_id)
end

p Human.find(1)
p Cat.find(1)
p Cat.find(2)

p Human.all[0]
p Cat.all

c = Cat.new(:id => 4, :name => "Gizmo", :owner_id => 1)
c.save
c = Cat.new(:name => "Gizmo", :owner_id => 2)
c.save
