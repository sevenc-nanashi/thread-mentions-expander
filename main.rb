require "discorb"
require "dotenv"

Dotenv.load

client = Discorb::Client.new

client.once :standby do
  puts "Logged in as #{client.user}"
end

load "./core.rb"

client.extend Core

client.run ENV["TOKEN"]
