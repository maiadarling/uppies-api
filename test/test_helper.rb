ENV["RAILS_ENV"] ||= "test"

# require 'simplecov'
# SimpleCov.start 'rails' do
#   add_filter '/test/'
#   # add_group 'Uploaders', 'app/uploaders'
#   # add_group "Models", "app/models"
#   # add_group "Controllers", "app/controllers"
#   # add_group "Jobs", "app/jobs"
#   # add_group "Demo", "app/controllers/demo"
#   # add_group "Api", "app/controllers/api"
# end

require_relative "../config/environment"
require "minitest/autorun"
require "rails/test_help"
require "factory_bot_rails"

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  # Run tests in parallel with specified workers
  # parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def fixture_file_path(file)
    File.join(Rails.root, "test", "fixtures", "files", file)
  end

  class << self
    def it(description, &block)
      test(description, &block)
    end

    def context(description, &block)
      block.call
    end
  end

  FactoryBot::SyntaxRunner.class_eval do
    include ActionDispatch::TestProcess
    include ActionDispatch::TestProcess::FixtureFile
    include ActiveSupport::Testing::FileFixtures

    def fixture_file_path(file)
      File.join(Rails.root, "test", "fixtures", "files", file)
    end

    def upload_file!(file, content_type)
      fixture_file_upload(fixture_file_path(file), content_type)
    end
  end
end
