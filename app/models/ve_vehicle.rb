class VeVehicle < ApplicationRecord

	include DbChange::Track

	has_many :ve_events, dependent: :restrict_with_error
	has_many :ve_mileages, dependent: :restrict_with_error
	has_many :ve_vehicle_users, dependent: :destroy
	has_many :users, through: :ve_vehicle_users
	
	has_many :documents, as: :obj

	def self.can_create? u, *args; u.admin?; end
	
	def label; [vehicle_no_was, year_was, make_was, model_was, name_was.blank? ? '' : "(#{name_was})"].reject(&:blank?) * ' '; end
	
	def year_make_model; [year, make, model].reject(&:blank?) * ' '; end
	def ymm; year_make_model; end
	def ymm_name; [ymm, name.blank? ? '' : "(#{name})"].reject(&:blank?) * ' '; end
	def no_ymm_name; [vehicle_no, ymm_name].reject(&:blank?) * ' '; end
	
	validates_presence_of :year, :make, :model, :license, :vehicle_no
	
	def self.assign_colors
		objs = where('active = 1').order('vehicle_no').to_a
		if objs.size > 0
			step = 1.0 / objs.size.to_f
			hue = 0.0
			objs.each { |o|
				o.update_attribute :color, RGB::Color.from_fractions(hue, 1.0, 0.3).to_rgb_hex
				hue += step
			}
		end
		where('active = 0').update_all('color = "#000000"')
	end
	
	attr :check_new_user_ids, true
	def new_user_ids; @new_user_ids || user_ids; end
	def new_user_ids= v
		@new_user_ids = v.map &:to_i
	end
	
	def handle_after_save
		if @check_new_user_ids
			ids = (@new_user_ids || []).map { |user_id|
				ve_vehicle_users.find_or_create_by(user_id: user_id).id
			}
			ve_vehicle_users.where.not(id: ids + [0]).delete_all
		end		
	end
	after_save :handle_after_save
	
	def can_reserve? u
		u.admin? || user_ids.empty? || u.id.in?(user_ids)
	end
	
	scope :reservable, -> (u, id = nil) {
		s = where(active: true)
		# Availability makes this problematic.
		#if u.admin?
		#	s = s.or(VeVehicle.where(id: id)) if id
		#else
		#	s = s.eager_load(:ve_vehicle_users).where('ve_vehicle_users.user_id is null or ve_vehicle_users.id = ?', u.id)
		#	s = s.or(VeVehicle.eager_load(:ve_vehicle_users).where(id: id)) if id
		#end
		s
	}
	
end