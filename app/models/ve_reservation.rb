class VeReservation < ApplicationRecord
	
	def self.can_edit? u, *args; u.admin?; end
	#def can_clone? u, *args; false; end

	include DbChange::Track

	has_many :ve_events, dependent: :destroy
	belongs_to :user, optional: true
	has_many :ve_reservation_users, dependent: :destroy
	has_many :users, through: :ve_reservation_users
	
	has_many :documents, as: :obj
	
	def label; [(begin_was ? begin_was.d : nil), title] * ' '; end
	
	def title; description.presence || auto_description; end
	
	attr :check_new_user_ids, true
	def new_user_ids; @new_user_ids || user_ids; end
	def new_user_ids= v
		@new_user_ids = v.map &:to_i
	end
	
	attr :check_new_user_ids, true
	def new_user_ids; @new_user_ids || user_ids; end
	def new_user_ids= v
		@new_user_ids = v.map &:to_i
	end
	
	def handle_before_create
		self.user ||= @current_user
	end
	before_create :handle_before_create
	
	def dup
		o = super
		o.new_user_ids = new_user_ids
		o.new_schedules = new_schedules
		o
	end
	
	def schedules
		scheds = []
		ve_events.future.order('date').group_by(&:times).transform_values { |v|
			v.group_by(&:ve_vehicle_id).map { |k, v| [[k], v.map(&:date)] }
		}.transform_values { |data|
			s = data.size
			i = 0
			while i < s
				j = 0
				while j < s
					if i != j
						common = data[i][1] & data[j][1]
						if common.size > 0
							data << [data[i][0] + data[j][0], common]
							data[i][1] -= common
							data[j][1] -= common
							s += 1
						end
					end
					j += 1
				end
			i += 1
			end
			data.reject { |d| d[1].empty? }
		}.each { |time, data|
			b, e = time.split('-').map { |t| Time.parse(t).strftime('%I:%M %P') rescue nil }
			scheds += data.map { |d| {ve_vehicle_ids: d[0], dates: d[1], begin_time: b, end_time: e}}
		}
		return scheds
	end
	
	attr :check_new_schedules, true
	def new_schedules
		@new_schedules ||= schedules.map { |s| s.dates = s.dates.join(','); s }
	end
	
	def new_schedules= v
		@new_schedules = (v.is_a?(Hash) ? v.values : v).map { |s|
			s.ve_vehicle_ids ||= []
			s.dates ||= ''
			s
		}
	end
	
	def has_past_events?; ve_events.past.exists?; end
	
	def handle_validate
		errors.add :base, 'You cannot edit this reservation' if !new_record? && !can_edit?(@current_user)
		if @check_new_schedules
			@new_events = []
			@new_schedules ||= []
			errors.add :base, 'No vehicles/date schedules entered' if @new_schedules.empty? && !has_past_events?
			@new_schedules.each_with_index { |s, i|
				j = i + 1
				dates = s.dates.split(',').map { |d| Date.parse(d) rescue nil }.select { |d| d && d >= Date.today }
				errs = []
				errs << "No vehicle selected for schedule ##{j}" if s.ve_vehicle_ids.empty?
				errs << "No dates selected for schedule ##{j}" if dates.empty?
				begin_time = nil
				end_time = nil
				if !s.begin_time.blank?
					begin_time = Time.parse(s.begin_time) rescue nil
					errs << "Invalid begin time for schedule ##{j}" if !begin_time || begin_time.strftime('%I:%M %P') != s.begin_time
				end
				if !s.end_time.blank?
					end_time = Time.parse(s.end_time) rescue nil
					errs << "Invalid end time for schedule ##{j}" if !end_time || end_time.strftime('%I:%M %P') != s.end_time
				end
				errs << "Begin time is after end time for schedule ##{j}" if end_time && begin_time && begin_time > end_time
				errs.each { |e| errors.add :base, e }
				if errs.empty? 
					s.ve_vehicle_ids.each { |ve_vehicle_id|
						v = VeVehicle.find(ve_vehicle_id)
						dates.each { |date|
							attr = {
								ve_vehicle: v,
								date: date, 
								begin_time: begin_time.try(:strftime, '%H:%M:%S'), 
								end_time: end_time.try(:strftime, '%H:%M:%S'),
							}
							e = ve_events.find_by(attr) || ve_events.build(attr)
							errors.add :base, "You cannot reserve vehicle ##{v.vehicle_no} for schedule ##{j}" if e.new_record? && !e.can_reserve?(@current_user)
							@new_events << e
						}
					}
				end
			}
			if !new_record?
				keep_ids = @new_events.map(&:id).reject(&:nil?)
				@delete_events = ve_events.future.where(keep_ids.empty? ? nil : ['id not in (?)', keep_ids])
				@delete_events.each { |e|
					errors.add :base, "You cannot delete #{e.label}" if !e.can_reserve?(@current_user)
				}
			end
			conflicts = @new_events.map(&:find_conflict).compact
			if !conflicts.empty?
				conflicts.each { |c|
					errors.add :base, "Conflicting vehicle reservation: #{c.label}"
				}
			end			
		end
	end
	validate :handle_validate, if: :current_user
	
	def handle_before_save
		if @check_new_user_ids
			self.auto_description = @new_user_ids.empty? ? (availability ? 'All User Availability' : 'No User Reservation') :
			User.find(@new_user_ids).map(&:username).join(', ')
		end
		@delete_events.delete_all if @delete_events
	end
	before_save :handle_before_save
	
	def handle_after_save
		#if @new_events
			#conflicts = @new_events.map(&:find_conflict).compact
			#if !conflicts.empty?
			#	conflicts.each { |c|
			#		errors.add :base, "Conflicting vehicle reservation: #{c.label}"
			#	}
			#	raise ActiveRecord::RecordInvalid::new(self)
			#end
			#keep_ids = @new_events.map &:id
			#ve_events.future.where(keep_ids.empty? ? nil : ['id not in (?)', keep_ids]).delete_all
		#end
		if @check_new_user_ids
			ids = (@new_user_ids || []).map { |user_id|
				ve_reservation_users.find_or_create_by(user_id: user_id).id
			}
			ve_reservation_users.where.not(id: ids + [0]).delete_all
		end
		update_date_range
	end
	after_save :handle_after_save
	
	def update_date_range
		DB.query('update ve_reservations r join (
				select min(date) min_date, max(date) max_date, ve_reservation_id from ve_events where ve_events.ve_reservation_id = ?
			) e on e.ve_reservation_id = r.id
			set r.begin = min_date, r.end = max_date where r.id = ?', id, id
		)	
	end
	
	def check_before_destroy
		errors.add :base, 'Cannot delete this reservation because it has days in the past' if has_past_events?
		super
	end
	
	# Availabilities can only be edited by the person who created it and admins.
	# Reservations can be edited by anyone in the reservation user list.
	def can_edit? u, *args
		return true if u.admin?
		u.id == user_id || (!availability && u.id.in?(user_ids))
	end

end