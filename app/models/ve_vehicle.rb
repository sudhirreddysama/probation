class VeVehicle < ApplicationRecord

	include DbChange::Track

	has_many :ve_events, :dependent => :restrict_with_error
	has_many :ve_mileages, :dependent => :restrict_with_error
	
	has_many :documents, as: :obj
	
	def label; "#{vehicle_no_was} (#{license_was}) #{year_was} #{make_was} #{model_was}"; end
	
	def year_make_model; "#{year} #{make} #{model}"; end
	
	validates_presence_of :year, :make, :model, :license, :vehicle_no
	
	def self.assign_colors
		objs = where('active = 1').order('vehicle_no').to_a
		if objs.size > 0
			step = 1.0 / objs.size.to_f
			hue = 0.0
			objs.each { |o|
				o.update_attribute :color, RGB::Color.from_fractions(hue, 1.0, 0.3).to_rgb_hex
				hue += step
			}
		end
		where('active = 0').update_all('color = "#000000"')
	end
	
end