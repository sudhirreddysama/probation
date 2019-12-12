class Object
	def yn; self ? 'yes' : 'no'; end
end

class NilClass
	def empty?; true; end
	def to_s(*a); ''; end
end

class Hash
	def + v; merge v; end

	def method_missing meth, *args
  	m = meth.to_s
  	if m =~ /=$/
  		self[m[0...-1]] = args[0]
    else
			self[m] || self[meth]
		end
	end
end

def FileUtils.num_lines path; `wc -l "#{path}"`.strip.split(' ')[0].to_i; end

# so we can (some date or date time or even nil).d --> '1/5/16'. Easy safe strings for views.
module DateTimeExt
	def t0
		nil? ? '' : strftime(min > 0 ? '%l:%M%P' : '%l%P').strip[0..-2]
	end
end
{
	d: '%-m/%-d/%y',
	d4: '%-m/%-d/%Y',
	dt: '%-m/%-d/%y %I:%M%p',
	dt4: '%-m/%-d/%Y %I:%M%p',
	t: '%I:%M%p',
	t2: '%H:%M:%S'
}.each { |k, v| 
	Date::DATE_FORMATS[k] = v
	Time::DATE_FORMATS[k] = v
	DateTimeExt.module_eval "def #{k}; to_s(:#{k}); end"
}

[Date, Time, DateTime, NilClass].each { |c|
	c.include DateTimeExt
}

# Easy formatters for numbers.
module NumericExt
	def n0; to_s(:rounded, precision: 0, delimiter: ','); end
	def n2; to_s(:rounded, precision: 2, delimiter: ','); end
	def n3; to_s(:rounded, precision: 3, delimiter: ','); end
end

[Integer, Fixnum, Bignum, Float, BigDecimal, NilClass].each { |c|
	c.include NumericExt
}

# Allows for commas in strings converted to ints.
class String
	alias_method :old_to_i, :to_i
	alias_method :old_to_d, :to_d
	alias_method :old_to_f, :to_f
	def to_i; gsub(',', '').old_to_i; end
	def to_d; gsub(',', '').old_to_d; end
	def to_f; gsub(',', '').old_to_f; end
end

class << BigDecimal
	alias_method :old_new, :new
	def new(*args)
		args.first.gsub!(',', '') if args.first.is_a?(String)
		old_new(*args)
	end
end

def BigDecimal(*args); BigDecimal.new(*args); end
	

# Force reasonable 2 digit year conversion. ActiveRecord is hard coded to NOT accept m/d/yy.	
module Force2DigitYear
	def self.included(base)
		class << base
			alias_method :old__parse, :_parse
			def _parse(s, c = true); old__parse(s, true); end
			alias_method :old_parse, :parse
			def parse(s, c = true); old_parse(s, true); end
		end
	end
end	
[Date, DateTime].each { |c| c.include Force2DigitYear }

class Numeric
	Alph = ("A".."Z").to_a
	def alph
		s, q = "", self
		(q, r = (q - 1).divmod(26)) && s.prepend(Alph[r]) until q.zero?
		s
	end
end

# Turning off transactions for this application because they slow down imports horribly.
#ActiveRecord::Base.connection.class.class_eval {
#	def begin_db_transaction; end
#	def commit_db_transaction; end
#}

