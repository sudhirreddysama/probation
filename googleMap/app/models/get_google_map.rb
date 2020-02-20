require 'net/http'
class GetGoogleMap 
	include ActiveModel::Model

	def self.get_url(params)
		google_config = Rails.application.secrets.google_info[params[:customer_name]]
		"https://maps.googleapis.com/maps/api/place/findplacefromtext/"+google_config["response output"]+"?key="+google_config["API Key"]+"&inputtype="+google_config["type"]+"&location="+params[:latitude].to_s+","+params[:longitude].to_s+"&language="+google_config["language"]+"&limit="+google_config["number of locations"].to_s
	end

	def self.http_request(params)
		begin
			uri = URI(self.get_url(params))
	    	res = Net::HTTP.get_response(uri)
    		return res.body if (res.code == "200")
		rescue
			return "May Api is failed..!"
		end
	end
end
