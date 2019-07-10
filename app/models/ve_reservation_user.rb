class VeReservationUser < VeRecord

	belongs_to :user
	belongs_to :ve_reservation

end