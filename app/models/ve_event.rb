class VeEvent < ApplicationRecord
	
	def self.can_edit? u, *args; u.admin?; end

	def can_edit? u, *args
		return false if date_was && (date_was < Date.today)
		ve_reservation.can_edit? u, *args
	end	
	def can_destroy? u, *args; can_edit? u, *args; end
	
	include DbChange::Track
	
	belongs_to :ve_reservation, optional: false
	belongs_to :ve_vehicle, optional: true # Optional for custom error message.
	has_many :documents, as: :obj
	
	scope :past, -> { where 'date(ve_events.date) < date(now())' }
	scope :future, -> { where 'date(ve_events.date) >= date(now())' }
	
	validates_presence_of :date

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
	

	def availability= v; @availability = ActiveModel::Type::Boolean.new.cast(v); end
	def availability; @availability.nil? ? ve_reservation.try(:availability) : @availability; end	
	
	attr :check_new_user_ids, true
	def new_user_ids; @new_user_ids || ve_reservation.try(:user_ids) || []; end
	def new_user_ids= v
		@new_user_ids = v.map(&:to_i).uniq
	end
	
	def handle_before_validation
		errors.add :ve_vehicle_id, '^Vehicle is required' if !ve_vehicle
		errors.add :base, 'You cannot reserve dates in the past' if date && (date < Date.today)
		errors.add :base, 'You cannot edit this reservation' if ve_reservation && !ve_reservation.can_edit?(@current_user)
		errors.add :base, 'You cannot reserve this vehicle' if ve_vehicle && !can_reserve?
		errors.add :base, 'Invalid time range' if begin_time && end_time && end_time < begin_time
		uids = @check_new_user_ids ? (@new_user_ids || []).sort : nil
		if !ve_reservation || (uids && ve_reservation.user_ids.sort != uids) || ve_reservation.description != description || ve_reservation.availability != availability
			if ve_reservation && ve_reservation.ve_events.count == 1
				r = ve_reservation
			else
				@ve_reservation_was = ve_reservation
				r = self.ve_reservation = VeReservation.new({
					user: @current_user
				})
			end	
			r.attributes = {
				description: description,
				new_user_ids: uids,
				check_new_user_ids: !!uids,
				availability: availability,
			}
		end
		c = find_conflict(true)
		errors.add :base, "Conflicting vehicle reservation: #{c.label}" if c
	end
	before_validation :handle_before_validation, if: :current_user
	
	# poor mans belongs_to autosave: true. No way to autosave conditionally. Without it causes infinite loop if ve_reservation is http posted.
	def handle_before_save
		ve_reservation.save
	end 
	before_save :handle_before_save, if: :current_user 
	
	def handle_after_save
		ve_reservation.try(:update_date_range)
		@ve_reservation_was.try(:update_date_range)
	end
	after_save :handle_after_save, if: :current_user 
	
	def handle_after_destroy
		if ve_reservation
			if ve_reservation.ve_events.count == 0
				ve_reservation.destroy
			else
				ve_reservation.update_date_range
			end
		end
	end
	after_destroy :handle_after_destroy
	
	scope :overlap, -> (ve_vehicle_id, date, begin_time = nil, end_time = nil) {
		where('ve_vehicle_id = ? and date = ?', ve_vehicle_id, date)
		.where(begin_time && ['end_time is null or end_time > ?', begin_time.t2])
		.where(end_time && ['begin_time is null or begin_time < ?', end_time.t2])
	}
	
	# Returns a hard false if availabilities prevent reservation. Returns true if availability engulfs and allows reservation. 
	# Yields if there's some ambiguity (partial overlap or no avail)
	def check_avails u, ve_vehicle_id, date, begin_time, end_time
		engulfed = false
		avails = VeEvent.eager_load(ve_reservation: :ve_reservation_users)
			.where('ve_reservations.availability = 1')
			.overlap(ve_vehicle_id, date, begin_time, end_time)
		avails.each { |a|
			return false if !a.ve_reservation.user_ids.empty? && !u.id.in?(a.ve_reservation.user_ids)
			# If the availability does not entirely contain the reservation, we must also check the vehicle user list. Note this does not properly
			# handle a reservation engulfed by two availabilities abutted next to each other. That also forces the check of the vehicle user list (in yield).
			# The user can just split their reservation up then...
			engulfed = true if (a.begin_time.nil? || (begin_time && a.begin_time <= begin_time)) && 
				(a.end_time.nil? || (end_time && a.end_time >= end_time))
		}
		return engulfed || yield
	end
	
	def can_reserve? u = nil
		u ||= @current_user
		return true if u.admin?
		# Have to check the availability of what the event was and what it will be.
		dont_check_was = new_record? || !(ve_vehicle_id_changed? || date_changed? || begin_time_changed? || end_time_changed?)
		return check_avails(u, ve_vehicle_id, date, begin_time, end_time) {
			ve_vehicle.user_ids.empty? || u.id.in?(ve_vehicle.user_ids)
		}
		# Actually, nevermind. If a user wants to edit their reservation to move it FROM something they're restricted from reserving TO something they can, let them.
		# Not 100% sure about this, so leaving commented out for now.
		#} && (dont_check_was || check_avails(u, ve_vehicle_id_was, date_was, begin_time_was, end_time_was) {
			#ve_vehicle_was = VeVehicle.find ve_vehicle_id_was
			#ve_vehicle_was.user_ids.empty? || u.id.in?(ve_vehicle_was.user_ids)			
		#})
	end
	
	def find_conflict within_res = false
		VeEvent.eager_load(:ve_reservation)
			.where(id ? ['ve_events.id != ?', id] : nil)
			.where(ve_reservation_id && !within_res ? ['ve_reservation_id != ?', ve_reservation_id] : nil)
			.where('availability = ?', ve_reservation.availability)
			.overlap(ve_vehicle_id, date, begin_time, end_time)
			.first
	end
	
end