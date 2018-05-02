module InitHelpers

  def new_bot
    config = YAML.load_file(fixture_file("config.yml"))
    username = config['bot']['username']
    password = config["bot"]["password"]
    hashtags = config['bot']['hashtags']

    feed_delay = 3200 #seconds before liking feed posts

    InstaBot.new(username, password, hashtags, feed_delay)
  end

end

