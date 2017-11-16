class VeMileage < ApplicationRecord

	include DbChange::Track

	belongs_to :ve_vehicle
	
	has_many :documents, as: :obj
	
	MONTHS = %i{jan feb mar apr may jun jul aug sep oct nov dec}
	
	validates_presence_of :ve_vehicle, message: '^Vehicle can\'t be blank'
	validates_presence_of :year
	validates_uniqueness_of :year, scope: :ve_vehicle_id
	
	def label; "#{year_was} - #{ve_vehicle.vehicle_no} #{ve_vehicle.year} #{ve_vehicle.make} #{ve_vehicle.model}"; end
	
	def self.setup_year y
		DB.query('insert into ve_mileages (ve_vehicle_id, year, year_start)
			select v.id, ?, m_py.dec from ve_vehicles v 
			left join ve_mileages m on m.ve_vehicle_id = v.id and m.year = ?
			left join ve_mileages m_py on m_py.ve_vehicle_id = v.id and m_py.year = ?
			where v.active = 1
			on duplicate key update year_start = values(year_start)', y, y, y.to_i -  1)
	end
	
end