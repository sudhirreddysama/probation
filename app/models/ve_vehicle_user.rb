class VeVehicleUser < ApplicationRecord

	belongs_to :user
	belongs_to :ve_vehicle

end