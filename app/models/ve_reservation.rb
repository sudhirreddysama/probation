class VeReservation < ApplicationRecord

	include DbChange::Track

	has_many :ve_events, dependent: :destroy
	belongs_to :user, optional: true
	has_many :ve_reservation_users, dependent: :destroy
	has_many :users, through: :ve_reservation_users
	
	has_many :documents, as: :obj
	
	validates_presence_of :description
	
	def label; [(begin_was ? begin_was.d : nil), description_was] * ' '; end

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
	
	def schedules
		scheds = []
		ve_events.order('date').group_by(&:times).transform_values { |v|
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
		@new_schedules = v.map { |i, s|
			s.ve_vehicle_ids ||= []
			s.dates ||= ''
			s
		}
	end
	
	def handle_validate
		errors.add :base, 'You cannot edit this reservation' if !new_record? && !can_edit?(@current_user)
		if @check_new_schedules
			self.begin = nil
			self.end = nil
			@new_events = []
			@new_schedules ||= []
			errors.add :base, 'No vehicles/date schedules entered' if @new_schedules.empty?
			@new_schedules.each_with_index { |s, i|
				j = i + 1
				dates = s.dates.split(',').map { |d| Date.parse(d) rescue nil }.compact
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
							errors.add :base, "You cannot reserve vehicle ##{v.vehicle_no} for schedule ##{j}" if !e.can_reserve?(@current_user)
							@new_events << e
							self.begin = [e.date, self.begin].compact.min
							self.end = [e.date, self.end].compact.max
						}
					}
				end
			}
		end
	end
	validate :handle_validate, if: :current_user
	
	def handle_after_save
		if @new_events
			conflicts = @new_events.map(&:find_conflict).compact
			if !conflicts.empty?
				conflicts.each { |c|
					errors.add :base, "Conflicting vehicle reservation: #{c.label}"
				}
				raise ActiveRecord::RecordInvalid::new(self)
			end
			keep_ids = @new_events.map &:id
			ve_events.where(keep_ids.empty? ? nil : ['id not in (?)', keep_ids]).delete_all
		end
		if @check_new_user_ids
			ids = (@new_user_ids || []).map { |user_id|
				ve_reservation_users.find_or_create_by(user_id: user_id).id
			}
			ve_reservation_users.where.not(id: ids + [0]).delete_all
		end		
	end
	after_save :handle_after_save
	
	# Availabilities can only be edited by the person who created it and admins.
	# Reservations can be edited by anyone in the reservation user list.
	def can_edit? u, *args
		return true if u.admin?
		u.id == user_id || (!availability && u.id.in?(user_ids))
	end

end