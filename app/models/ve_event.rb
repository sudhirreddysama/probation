class VeEvent < ApplicationRecord

	belongs_to :ve_reservation
	belongs_to :ve_vehicle

	def times
		(begin_time ? begin_time.strftime('%H:%M:%S') : '') + '-' + (end_time ? end_time.strftime('%H:%M:%S') : '')
	end

end