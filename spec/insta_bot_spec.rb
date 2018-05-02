require 'spec_helper'
require 'insta_bot'

# It's OK to test your private methods...
# Feed in Ruby objects that are similar to what Instagram would return...

describe InstaBot do

  context "#build_shortcode_array" do
    it "returns array of shortcodes" do
      bot = new_bot
      json = get_json
      shortcode_ary = ["BiQW0FNnaPz", "BiQWyvqh0Lz", "BiQWuwYl-yd",
                       "BiQWnkYg_SI", "BiQWnWnj-eP", "BiQWiwylF1j"]
      expect(bot.send :build_shortcode_array, json).to eq shortcode_ary
    end
  end

end
