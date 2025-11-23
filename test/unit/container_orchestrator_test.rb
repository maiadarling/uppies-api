require "test_helper"

class ContainerOrchestratorTest < ActiveSupport::TestCase
  def setup
    @user = FactoryBot.create(:user)
    @site = FactoryBot.create(:site, owner: @user, creator: @user)
    @orchestrator = ContainerOrchestrator.new
  end

  context "containers" do
    it "lists running site containers" do
      containers = @orchestrator.containers
      assert containers.is_a?(Array)
    end
  end
end
