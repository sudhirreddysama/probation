class VeReservation < ApplicationRecord

	include DbChange::Track

	has_many :ve_events, dependent: :destroy
	belongs_to :user
	
	validates_presence_of :description
	
	def label; [(begin_was ? begin_was.d : nil), description_was] * ' '; end
	
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
	
	def new_schedules
		@new_schedules ||= schedules.map { |s| s.dates = s.dates.join(','); s }
	end
	
	def new_schedules= v
		@new_schedules = v.map { |i, s|
			s.ve_vehicle_ids ||= []
			s.dates ||= ''
			#s.begin_time = Time.parse(s.begin_time) rescue nil
			#s.end_time = Time.parse(s.end_time) rescue nil
			s
		}
	end
	
	attr :check_new_schedules, true
	
	def handle_before_save

	end
	before_save :handle_before_save
	
	def handle_validate
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
				errs << "Begin time is after end time for schedule ##{i}" if end_time && begin_time && begin_time > end_time
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
							@new_events << e
							self.begin = [e.date, self.begin].compact.min
							self.end = [e.date, self.end].compact.min
						}
					}
				end
			}
		end
	end
	validate :handle_validate
	
	def handle_after_save
		if @new_events
			conflicts = []
			@new_events.each { |e|
				conflict = VeEvent.where('ve_reservation_id != ? and ve_vehicle_id = ? and date = ?', id, e.ve_vehicle_id, e.date)
					.where(e.begin_time ? ['end_time is null or end_time > ?', e.begin_time] : nil)
					.where(e.end_time ? ['begin_time is null or begin_time < ?', e.end_time] : nil)
					.first
				conflicts << conflict if conflict
			}
			if !conflicts.empty?
				conflicts.each { |c|
					v = c.ve_vehicle
					r = c.ve_reservation
					lbl = [c.date.d, [c.begin_time, c.end_time].compact.map(&:t0) * '-', v.vehicle_no, v.year_make_model, r.description].reject(&:blank?) * ' '
					errors.add :base, "Conflicting vehicle reservation: #{lbl}"
				}
				raise ActiveRecord::RecordInvalid::new(self)
			end
			keep_ids = @new_events.map &:id
			ve_events.where(keep_ids.empty? ? nil : ['id not in (?)', keep_ids]).delete_all
		end
	end
	after_save :handle_after_save
	
	def handle_before_create
		self.user = @current_user
	end
	before_create :handle_before_create

end