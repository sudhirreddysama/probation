module DateRangeOptions
	
	def self.options key = nil
		return future if key == 'future'
		return default
	end
	
	def self.options_for_select key = nil
		opt = options(key)
		opt.map { |val, label, d1, d2| [label, val, data: {d1: d1.d, d2: d2.d}] }
	end
	
	def self.dates_for_key k
		o = default.assoc(k) || future.assoc(k)
		return o&.slice 2, 2
	end
	
	def self.load_filter_date_preset filter
		if !filter.date_preset.blank?
			d1, d2 = DateRangeOptions.dates_for_key(filter.date_preset)
			filter.from_date, filter.to_date = d1.d, d2.d
		end	
	end
	
	def self.default
		t = Date.today
		tm1 = t - 1
		tp1 = t + 1
		m = t.beginning_of_month
		w = t.beginning_of_week(:sunday)
		y = t.beginning_of_year 
		return [
			['day_0', "Today", t, t],
			['day_m1', "Yesterday", tm1, tm1],
			['day_1', "Tomorrow", tp1, tp1],
			['week_0', "This Week", w, (w + 6)],
			['week_m1', "Last Week", (w - 7), (w - 1)],
			['week_1', "Next Week", (w + 7), (w + 13)],
			['month_0', "This Month", m, m.end_of_month ],
			['month_m1', "Last Month", m.last_month, (m - 1)],
			['month_1', "Next Month", m.next_month, m.next_month.end_of_month],
			['year_0', "This Year", y, y.end_of_year],
			['year_m1', "Last Year", y.last_year, (y - 1)],
			['year_1', "Next Year", y.next_year, y.next_year.end_of_year]		
		]
	end
	
	def self.future
		t = Date.today
		m1 = t.beginning_of_month
		m2 = m1.advance(months: 1)
		m3 = m1.advance(months: 2)
		m4 = m1.advance(months: 3)
		m5 = m1.advance(months: 4)
		m6 = m1.advance(months: 5)
		m7 = m1.advance(months: 6)
		m8 = m1.advance(months: 7)
		w1 = t.beginning_of_week(:sunday)
		w2 = w1.advance(weeks: 1)
		w3 = w1.advance(weeks: 2)
		w4 = w1.advance(weeks: 3)
		w5 = w1.advance(weeks: 4)
		w6 = w1.advance(weeks: 5)
		return [
			['week_0', "This Week (#{w1.strftime('%m/%d')})", w1, (w1 + 6)],
			['week_1', "Next Week (#{w2.strftime('%m/%d')})", w2, (w2 + 6)],
			['week_2', "Week of #{w3.strftime('%m/%d')}", w3, (w3 + 6)],
			['week_3', "Week of #{w4.strftime('%m/%d')}", w4, (w4 + 6)],
			['week_4', "Week of #{w5.strftime('%m/%d')}", w5, (w5 + 6)],
			['week_5', "Week of #{w6.strftime('%m/%d')}", w6, (w6 + 6)],
			['month_0', "This Month (#{m1.strftime('%b')})", m1, m1.end_of_month],
			['month_1', "Next Month (#{m2.strftime('%b')})", m2, m2.end_of_month],
			['month_2', "#{m3.strftime('%B')}", m3, m3.end_of_month],
			['month_3', "#{m4.strftime('%B')}", m4, m4.end_of_month],
			['month_4', "#{m5.strftime('%B')}", m5, m5.end_of_month],
			['month_5', "#{m6.strftime('%B')}", m6, m6.end_of_month],
			['month_6', "#{m7.strftime('%B')}", m7, m7.end_of_month],
			['month_7', "#{m8.strftime('%B')}", m8, m8.end_of_month],
		]
	end

end