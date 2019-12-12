#
# Bypass ActiveRecord.
#
# Takes queries in two formats:
#
# DB.queryf('select * from whatever where id = %d and name = "%s" and some_float = "%f"', 1, 'guy', 54.54)
# DB.query('select * from whatever where id = ? and name = ? and some_float = ?', 1, 'guy', 54.54)
#
#
module DB
	
	def self.raw q
		ActiveRecord::Base.connection.exec_query q
	end

	def self.query *args
		raw escape(*args)
	end
	
	def self.queryf *args
		raw escapef(*args)
	end
	
	def self.escape *args
		ActiveRecord::Base.send(:sanitize_sql_array, args)
	end
	
	def self.escapef q, *args
		q % args.collect { |arg| quote arg.to_s }
	end
	
	def self.quote s = ''
		ActiveRecord::Base.connection.quote_string(s.to_s)
	end
	
end


