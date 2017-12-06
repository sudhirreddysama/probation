class IcalController < ApplicationController


	skip_before_filter :require_login, only: :ve
	
	def index 
		@filter ||= {}
		@filter.user_ids ||= []
		@filter.ve_vehicle_ids ||= []
	end
	
	def ve
		cal = Icalendar::Calendar.new
		cond = ['ve_events.date >= date_add(date(now()), interval -30 day)']
		user_ids = params.id.to_s.split('-').map(&:to_i).select { |i| i > 0 }.uniq
		ve_vehicle_ids = params.id2.to_s.split('-').map(&:to_i).select { |i| i > 0 }.uniq
		cond << DB.escape('ve_reservation_users.user_id in (?)', user_ids) if !user_ids.empty?
		cond << DB.escape('ve_events.ve_vehicle_id in (?)', ve_vehicle_ids) if !ve_vehicle_ids.empty?
		VeEvent.where(get_where(cond)).eager_load(:ve_vehicle, {ve_reservation: :ve_reservation_users}).each { |e|
			cal.event { |ev|
				d = e.date
				t1 = e.begin_time
				t2 = e.end_time
				ev.dtstart = t1 ? DateTime.new(d.year, d.month, d.day, t1.hour, t1.min, t1.sec) : Icalendar::Values::Date.new(d.strftime('%Y%m%d'))
				ev.dtend = t2 ? DateTime.new(d.year, d.month, d.day, t2.hour, t2.min, t2.sec) : Icalendar::Values::Date.new(d.strftime('%Y%m%d'))
				v = e.ve_vehicle
				r = e.ve_reservation
				ev.summary = "#{r.description} (#{v.vehicle_no} #{v.year_make_model})"
				ev.description = r.notes
				ev.url = url_for controller: :ev_event, action: :view, id: e.id
			}
		}
		render text: cal.to_ical, content_type: 'text/calendar'
	end

end