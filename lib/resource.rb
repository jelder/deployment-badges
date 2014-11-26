class Resource

  attr_reader :id
  attr_reader :attributes

  FIELDS = %i[
    github
    app
    user
    url
    head
    head_long
    git_log
  ]

  def initialize(attributes = {})
    @id = attributes.delete(:id) or raise ArgumentError, "This isn't Postgres. You need to come up with your own primary keys."
    attributes.assert_valid_keys(FIELDS)
    @attributes = attributes
  end

  def [](key)
    @attributes[key]
  end

  def []=(key, value)
    @attributes[key] = value
  end

  def to_h
    @attributes
  end

  def save
    $redis.hmset(id, *@attributes.slice(*FIELDS).merge(updated_at: Time.now.to_i).flatten) == "OK"
  end

  def self.find(id)
    result = $redis.hmget id, FIELDS
    return if result.compact.empty?
    new(FIELDS.zip(result).to_h.merge(id: id))
  end

end