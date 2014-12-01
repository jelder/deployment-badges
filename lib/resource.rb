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
    updated_at
  ]

  def initialize(attributes = {})
    @id = attributes.delete(:id) or raise ArgumentError, "This isn't Postgres. You need to come up with your own primary keys."
    @attributes = attributes.symbolize_keys
    @attributes.assert_valid_keys(FIELDS)
  end

  def assign_attributes(attributes)
    @attributes.merge!(attributes.symbolize_keys.slice(*FIELDS))
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

  def compare_url
    "https://github.com/#{@attributes[:github]}/compare/master...#{@attributes[:head_long]}"
  end

  def age
    (Time.now.to_i - attributes[:updated_at].to_i)
  end

  def color
    case age / (60 * 60)
    when  0...2  then "#7ac631"
    when  2...4  then "#ffda39"
    when  4...8  then "#f9b600"
    when  8...16 then "#f4932c"
    when 16...32 then "#ff6000"
    else
      "#e53f00"
    end
  end

  def style
    "fill: #{color}"
  end

  def save
    @attributes.symbolize_keys!
    @attributes.assert_valid_keys(FIELDS)
    $redis.hmset(id, *@attributes.slice(*FIELDS).merge(updated_at: Time.now.to_i).flatten) == "OK"
  end

  def self.find(id)
    result = $redis.hmget id, FIELDS
    return if result.compact.empty?
    new(FIELDS.zip(result).to_h.merge(id: id))
  end

end