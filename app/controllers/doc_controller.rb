class DocController < ApplicationController

	skip_before_filter :require_login

	def view
		if !params.id.blank? && !params.id2.blank?
			@obj = Document.find_by(id: params.id, download_key: params.id2)
		end
		if @obj
			@obj.ensure_rendered
			send_file @obj.path
		else
			render text: 'Not Found!', status: '404'
		end
	end

end



		