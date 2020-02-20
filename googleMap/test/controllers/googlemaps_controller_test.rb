require 'test_helper'

class GooglemapsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get googlemaps_index_url
    assert_response :success
  end

end
