require 'rspec'
require 'pathname'

ROOT = Pathname(File.expand_path(File.join(File.dirname(__FILE__), '..')))
require File.join(ROOT, 'lib', 'insta_bot')

Dir[File.join(ROOT, 'spec', 'support', '**', '*.rb')].each{|f| require f }


RSpec.configure do |config|
  config.include JsonHelpers
  config.include InitHelpers
  config.include TestData
end
