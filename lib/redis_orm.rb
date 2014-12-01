class RedisOrm

  attr_reader :id
  attr_reader :key
  attr_reader :attributes

  def self.fields
    raise ArgumentError.new "Must be overridden in subclasses"
  end

  def initialize(attributes = {})
    @id = attributes.delete(:id) or raise ArgumentError, "This isn't Postgres. You need to come up with your own primary keys."
    @key = self.class.key(id)
    @attributes = attributes.symbolize_keys
    @attributes.assert_valid_keys(self.class.fields)
  end

  def assign_attributes(attributes)
    @attributes.merge!(attributes.symbolize_keys.slice(*self.class.fields))
  end

  def [](key)
    attributes[key]
  end

  def []=(key, value)
    attributes[key] = value
  end

  def to_h
    attributes
  end

  def save
    attributes.symbolize_keys!
    attributes.assert_valid_keys(self.class.fields)
    $redis.hmset(key, *attributes.slice(*self.class.fields).merge(updated_at: Time.now.to_i).flatten) == "OK"
  end

  def self.find(id)
    result = $redis.hmget key(id), fields
    return if result.compact.empty?
    new(fields.zip(result).to_h.merge(id: id))
  end

  def self.create_or_update(id, attributes)
    instance = Resource.find(id) || Resource.new(id: id)
    instance.assign_attributes(attributes)
    instance.save
    return instance
  end

  def self.key(id)
    "#{name}_#{id}"
  end

end