class Resource < RedisOrm

  def self.fields
    %i[
      github
      app
      user
      url
      head
      head_long
      git_log
      updated_at
    ].freeze
  end

  def compare_url
    "https://github.com/#{attributes[:github]}/compare/master...#{attributes[:head_long]}"
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

end