class Resource < RedisOrm

  attr_reader :id
  attr_reader :attributes

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


end