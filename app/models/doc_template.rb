class DocTemplate < ApplicationRecord

	include DbChange::Track
	
	has_many :documents
	
	TPL_MODELS = [
	#	['o', FdEstablishment], 
	#	['o', FdChurch], 
	#	['o', PlPool],
	#	['o', TfFacility], 
	#	['o', TrChildCamp], 
	#	['o', TrDaycare], 
	#	['o', TrTanning], 
	#	['o', TrOther]
	]
	
	def self.base_vars
		{'Variables' => [
			'current_date.d',
			'current_date.d4',
			'current_user.name',
			'current_user.initials',
			'current_user.username',
			'eh_header'
		]}
	end
	
	def self.vars
		return @vars if @vars
		@vars = base_vars
		TPL_MODELS.each { |k, m|
			fields = []
			m.columns.each { |c|
				if c.type.in?([:datetime, :timestamp, :date])
					fields << "#{k}.#{c.name}.d"
					fields << "#{k}.#{c.name}.d4"
				else
					fields << "#{k}.#{c.name}"
				end
			}
			@vars[m.to_s.titleize] = fields
		}
		return @vars
	end
	
	validates_presence_of :name

	def label; name_was; end
	
	class DocTemplateVariables < Hash
		
		def eh_header
			ApplicationController.render layout: false, template: 'doc_templates/eh_header', assigns: {obj: self}
		end
	
	end
	
	def apply obj, user
		DocTemplate.apply body, obj, user
	end
	
	def self.apply body, obj, user
		v = DocTemplateVariables.new
		v.o = obj
		v.current_date = Time.now
		v.current_user = user
		vars = DocTemplate.vars.values.sum.uniq # Gets flat list of vars
		html = body.gsub(/\$\$(.*?)\$\$/) { |m|
			$1.in?(vars) ? (v.instance_eval($1) rescue '') : m
		}
		# Lets block level vars break out of paragraphs/divs.
		html = html.gsub('<p><!-- BLOCK -->', '').gsub('<!-- /BLOCK --></p>', '').gsub('<div><!-- BLOCK -->', '').gsub('<!-- /BLOCK --></div>', '')
		return html	
	end
	
end