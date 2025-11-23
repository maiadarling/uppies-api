require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  include Rails.application.routes.url_helpers

  def setup
    @user = FactoryBot.create(:user)
  end

  context "authentication" do
    it "requires authentication" do
      get sites_path
      assert_response :bad_request
      assert_equal "You must be logged in to access this resource", JSON.parse(response.body)["error"]
    end

    it "denies access with invalid token" do
      get sites_path, headers: { "X-Uppies-Key" => "invalid" }
      assert_response :unauthorized
      assert_equal "Access Denied", JSON.parse(response.body)["error"]
    end

    it "authenticates with valid token" do
      get sites_path, headers: { "X-Uppies-Key" => @user.token }
      assert_response :success
    end
  end
end
