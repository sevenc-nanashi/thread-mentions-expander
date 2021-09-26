require "discorb"

module Core
  extend Discorb::Extension

  Mention = Struct.new(:id, :name, :url, :before, :after)
  message_command "スレッドのメンションを表示" do |interaction, message|
    interaction.defer_source.wait
    mentions = Core.fetch_mentions(message)
    resp = mentions.map do |mention|
      "#{mention.before}[`##{mention.name}`](#{mention.url})#{mention.after}"
    end.join("\n")
    interaction.post resp.empty? ? "メンションは含まれていません。" : resp
  end

  event :reaction_add do |event|
    next unless event.emoji == Discorb::UnicodeEmoji["thread"]

    message = event.fetch_message.wait

    next if message.reactions.find { |reaction| reaction.emoji == Discorb::UnicodeEmoji["thread"] }.count > 1

    message.channel.typing do
      mentions = Core.fetch_mentions(message)
      resp = mentions.map do |mention|
        "#{mention.before}`##{mention.name}`#{mention.after} #{mention.url}"
      end
      message.reply resp.empty? ? "メンションは含まれていません。" : resp.join("\n")
    end
  end

  class << self
    def fetch_mentions(message)
      message.content.scan(/(.{,5})<#(\d+)>(.{,5})/).map do |before, id, after|
        thread = @client.channels[id] || @client.fetch_channel(id).wait

        next if thread.nil?

        Mention.new(
          id,
          thread.name,
          "https://discord.com/channels/#{message.guild.id}/#{id}",
          before,
          after
        )
      end
    end
  end
end
