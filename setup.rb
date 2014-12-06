#!/usr/bin/env ruby

require './app.rb'

Resource.create_or_update(1, {
  github: "jelder/deployment-badges",
  app: "deployment-badges",
  user: "jelder",
  url: "https://deployment-badges.herokuapp.com/",
  head: "abcdef",
  head_long: "abcdef",
  git_log: "Demo",
  updated_at: Time.now.to_i
})
