class VeEvent < ApplicationRecord

	include DbChange::Track
	
	belongs_to :ve_reservation, optional: false
	belongs_to :ve_vehicle, optional: false
	
	has_many :documents, as: :obj
	
	validates_presence_of :description, :date

	def times
		(begin_time ? begin_time.strftime('%H:%M:%S') : '') + '-' + (end_time ? end_time.strftime('%H:%M:%S') : '')
	end
	
	def label
		v = ve_vehicle
		r = ve_reservation
		[date.d, [begin_time, end_time].compact.map(&:t0) * '-', v.try(:vehicle_no), v.try(:year_make_model), r.try(:description)].reject(&:blank?) * ' '
	end
	
	attr :description, true
	def description; @description || ve_reservation.try(:description); end
	
	attr :check_new_user_ids, true
	def new_user_ids; @new_user_ids || ve_reservation.try(:user_ids) || []; end
	def new_user_ids= v
		@new_user_ids = v.map(&:to_i).uniq
	end
	
	def handle_before_validation
		errors.add :base, 'You cannot edit this reservation' if !new_record? && !can_edit?(@current_user)
		if ve_vehicle && (new_record? || ve_vehicle_id_changed?) && !ve_vehicle.can_reserve?(@current_user)
			errors.add :base, 'You cannot reserve this vehicle'
		end
		c = find_conflict		
		errors.add :base, "Conflicting vehicle reservation: #{c.label}" if c
		errors.add :base, 'Invalid time range' if begin_time && end_time && end_time < begin_time
		if !ve_reservation || ve_reservation.user_ids.sort != new_user_ids.sort || ve_reservation.description != description
			if ve_reservation && ve_reservation.ve_events.count == 1
				r = ve_reservation
			else
				r = self.ve_reservation = VeReservation.new({user: @current_user})
			end	
			r.attributes = {
				description: description,
				notes: ve_reservation.notes,
				new_user_ids: new_user_ids,
				check_new_user_ids: true,
				begin: [r.begin, date].compact.min,
				end: [r.end, date].compact.max
			}
		end
	end
	before_validation :handle_before_validation, if: :current_user
	
	# poor mans belongs_to autosave: true. No way to autosave conditionally. Without it causes infinite loop if ve_reservation is http posted.
	def handle_before_save
		ve_reservation.save
	end 
	before_save :handle_before_save, if: :current_user 
	
	def handle_after_destroy
		if ve_reservation && ve_reservation.ve_events.count == 0
			ve_reservation.destroy
		end
	end
	after_destroy :handle_after_destroy
	
	def find_conflict 	
		VeEvent.where(id ? ['ve_events.id != ?', id] : nil).where('ve_vehicle_id = ? and date = ?', ve_vehicle_id, date)
			.where(begin_time ? ['end_time is null or end_time > ?', begin_time] : nil)
			.where(end_time ? ['begin_time is null or begin_time < ?', end_time] : nil)
			.first
	end
	
	def can_edit? u, *args
		ve_reservation.can_edit? u, *args
	end
	
end