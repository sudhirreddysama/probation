class DbGroup < ApplicationRecord
	
	def can_create? u, *args; true; end
	
	has_many :db_group_objs, autosave: true, dependent: :destroy
	
	validates_presence_of :name
	
	def label; name_was; end
	
	attr_accessor :check_new_objs, :new_objs
	
	def new_objs
		@new_objs ||= db_group_objs.eager_load(obj_type.underscore.to_sym)
	end
	
	def placeholder_id
		id || "__NEW__#{name}"
	end
	
	def handle_before_validation
		if @check_new_objs
			objs = db_group_objs
			@new_objs ||= []
			@new_objs = @new_objs.values.map { |attr|
				next if attr.obj_id.blank?
				o = attr.id.blank? ? objs.build : objs.find { |a| a.id == attr.id.to_i }
				o.attributes = attr
				o
			}.compact
			ids = @new_objs.map(&:id).compact
			objs.each { |o| o.mark_for_destruction if o.id && !o.id.in?(ids) } if !ids.empty?
		end
	end
	before_validation :handle_before_validation
	
	module HasGroups
		extend ActiveSupport::Concern
		
		included {
			_class_name = to_s
			has_many :db_group_objs, foreign_key: :obj_id
			has_many :db_groups, -> { where obj_type: _class_name}, through: :db_group_objs
			
			DbGroupObj.belongs_to(to_s.underscore.to_sym, foreign_key: 'obj_id', class_name: to_s)
			
			DbGroup.has_many(to_s.tableize.to_sym, through: :db_group_objs)
			
			after_save :handle_after_save_db_groups
			
		}
		
		class_methods {
			def db_groups
				DbGroup.where obj_type: to_s
			end
		}
		
		def new_db_group_ids
			@new_db_group_ids ||= db_group_ids
		end
		
		def new_db_group_ids= v
			@new_db_group_ids = v.reject(&:blank?).map { |str| str.match(/^__NEW__/) ? str : str.to_i }
		end
		
		def handle_after_save_db_groups
			if @new_db_group_ids
				ids = @new_db_group_ids.map { |str|
					g = str.to_s.match(/^__NEW__(.*)$/) ? self.class.db_groups.create(name: $1) : self.class.db_groups.find(str)
					g.id
				}
				self.db_group_ids = ids
			end
		end
		
	end

end