class MassObject
  def self.set_attrs(*attributes)
    @attributes = []
    attributes.each do |att|
      attr_accessor att
      @attributes << att
    end
  end

  def self.attributes
    @attributes
  end

  def self.parse_all(results)
    results.map do|row_hash|
      new(row_hash)
    end
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      if self.class.attributes.include?(attr_name.to_sym)
        send("#{attr_name}=",value)
      else
        raise "mass assignment to unregistered attribute #{attr_name}!"
      end
    end
  end

  private
  def self.new_attr_accessor(*attrs)
    attrs.each do |attr|

      define_method(attr) do
        instance_variable_get(:@attr)
      end

      define_method("#{attr.to_s}=") do |new_val|
        instance_variable_set(:@attr, new_val)
      end

    end
  end

end

class NewClass < MassObject
  set_attrs :x, :y
end
