require "test_helper"

class ContainerOrchestratorTest < ActiveSupport::TestCase
  def setup
    @user = FactoryBot.create(:user)
    @site = FactoryBot.create(:site, owner: @user, creator: @user)
  end
end
