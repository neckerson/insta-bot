require 'rspec'
require 'capybara-webkit'
require 'capybara/dsl'
require 'json'
require 'yaml'
require 'logger'

class InstaBot

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

    start_logger

    if logged_in?
    else
      do_login
      if logged_in?
        @logger.info 'Logged in ' + @username
      else
        @logger.error 'Did not log in ' + @username
      end
    end

    loop do
      if @time_now < @time_future
        do_hashtag_likes
      else
        do_feed_likes
        reset_time_future
      end
      @time_now = Time.new()
    end

  end

  def do_hashtag_likes
    get_random_tag
    build_shortcode_array(get_page_json)
    do_likes
    sleep 30
  end

  def do_feed_likes
    @logger.info 'loading feed page'
    get_feed_page
    build_shortcode_array(get_page_json)
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

  def do_login
    visit 'accounts/login/'
    fill_in 'username', with: @username
    fill_in 'password', with: @password
    click_button 'Log in'
  end

  def get_page_json
    json_xpath = "//script[contains(., 'window._sharedData = {')]"
    json = find :xpath, json_xpath, visible: false
    JSON.parse(json[:text][21..-1].chop!)
  end

  def build_shortcode_array(json)
    @shortcode_array = Array.new
    quarried_shortcodes = json.dig('entry_data', 'TagPage', 0, 'graphql',
                                   'hashtag', 'edge_hashtag_to_media',
                                   'edges')&.map {
                                     |s| s.dig('node', 'shortcode')
                                   }
    @shortcode_array += quarried_shortcodes || []
  end

  def do_likes
    @shortcode_array.each do |t|
      like_image(t)
      @logger.info "Liked shortcode /" + t
      sleep @sleep_intervals.sample
    end
  end

  def get_random_tag
    tag = @hashtags.sample
    @logger.info 'loaded tag: ' + tag
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

  def start_logger
    @logger = Logger.new('logfile.log')
  end

end
