class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  
  def label; "#{self.class} #{id}"; end
  
  attr :current_user, true
  
	def self.can_create? u, *args; true || u.admin?; end
	def can_clone? u, *args; can_edit?(u, *args) && self.class.can_create?(u, *args); end
	def self.can_edit? u, *args; can_create? u, *args; end
	def can_edit? u, *args; self.class.can_edit? u, *args; end
	def self.can_destroy? u, *args; can_edit? u, *args; end
	def can_destroy? u, *args; self.class.can_destroy? u, *args; end

  def check_before_destroy
  	errors.add :base, 'You cannot delete this record' if !can_destroy?(@current_user)
  	throw :abort if !errors.empty?
  end
  before_destroy :check_before_destroy, if: :current_user
  
  def check_before_create
  	errors.add :base, 'You cannot create this record' if !self.class.can_create?(@current_user)
  	throw :abort if !errors.empty?
  end
  before_create :check_before_create, if: :current_user
  
  def check_before_update
  	errors.add :base, 'You cannot edit this record' if !can_edit?(@current_user)
  	throw :abort if !errors.empty?
  end
  before_update :check_before_update, if: :current_user

	def self.columns_by_type *types
		columns.select { |c| c.type.in?(types) }.map &:name
	end
  
  def self.number_attributes
  	columns_by_type :primary_key, :integer, :bigint, :float, :decimal, :numeric
  end
  
  def self.datetime_attributes
  	columns_by_type :datetime, :time, :date
  end
  
  def self.text_attributes
  	columns_by_type :string, :text
  end
  
  def self.scope_for_class_context c; where(:obj_type => c.to_s); end
  
end
