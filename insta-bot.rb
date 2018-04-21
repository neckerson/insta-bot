require 'rspec'
require 'capybara-webkit'
require 'capybara/dsl'
require 'json'
require 'yaml'

config = YAML.load_file('config.yml')
username = config['bot']['username']
password = config["bot"]["password"]
hashtags = config['bot']['hashtags']

feed_delay = 5400 #seconds before liking feed posts

class Account

  include RSpec::Matchers
  include Capybara::DSL

  def initialize(username, password, hashtags, feed_delay)
    @username = username
    @password = password
    @hashtags = hashtags
    @feed_delay = feed_delay
    @time_now = Time.new()
    @time_future = Time.new() + feed_delay
    @sleep_intervals = [60, 30, 70, 63, 45, 43, 32]
  end

  def run

    init_capybara

    if logged_in?
    else
      do_login
      if logged_in?
        confirm_logged_in
      else
        puts 'not logged in'
      end
    end

    loop do
      if @time_now < @time_future
        hashtag_likes
      else
        feed_likes
        reset_time_future
      end
      @time_now = Time.new()
    end

  end

  def hashtag_likes
    get_random_tag
    build_shortcode_array
    do_likes
    sleep 30
  end

  def feed_likes
    puts 'loading feed page'
    get_feed_page
    build_shortcode_array
    do_likes
  end

  private

  def init_capybara
    Capybara.run_server = false
    Capybara.current_driver = :webkit
    Capybara.app_host = "https://www.instagram.com/"
    Capybara::Webkit.configure do |config|
      config.allow_unknown_urls
      config.ignore_ssl_errors
    end
  end

  def logged_in?
    has_xpath?("//*[contains(@class, 'js logged-in')]")
  end

  def confirm_logged_in
    puts 'logged in ' + @username
  end

  def do_login
    visit 'accounts/login/'
    fill_in 'username', with: @username
    fill_in 'password', with: @password
    click_button 'Log in'
  end

  def build_shortcode_array

    @shortcode_array = Array.new
    json_xpath = "//script[contains(., 'window._sharedData')]"

    json = find :xpath, json_xpath, visible: false

    hash = JSON.parse(json[:text][21..-1].chop!)

    hash['entry_data']['TagPage'][0]['graphql']['hashtag']['edge_hashtag_to_media']['edges'].each { |obj|

      @shortcode_array.push obj['node']['shortcode']

    }
    puts 'Array of ' + @shortcode_array.length.to_s + ' like targets built'
  end

  def do_likes
    @shortcode_array.each do |t|
      like_image(t)
      puts "Liked shortcode /" + t
      sleep @sleep_intervals.sample
    end
  end

  def get_random_tag
    tag = @hashtags.sample
    puts 'loaded tag: ' + tag
    visit 'explore/tags/'+ tag
  end

  def get_feed_page
    visit @username
  end

  def like_image(shortcode)
    visit 'p/' + shortcode + '/'
    find(:xpath,"//*[text()='Like']").click
  end

  def reset_time_future
    @time_future = Time.new() + @feed_delay
  end
end

bot = Account.new(username, password, hashtags, feed_delay)
bot.run
