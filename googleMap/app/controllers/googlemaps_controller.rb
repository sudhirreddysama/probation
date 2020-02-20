class GooglemapsController < ApplicationController
  def index
  end

  def google_map_result
  	render text: GetGoogleMap.http_request(params)
  end
end