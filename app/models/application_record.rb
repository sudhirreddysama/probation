class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  
  def label; "#{self.class} #{id}"; end
  
  attr :current_user, true
  
	def self.can_create? u, *args; true || u.admin?; end
	def can_clone? u, *args; can_edit? u, *args; end
	def self.can_edit? u, *args; can_create? u, *args; end
	def can_edit? u, *args; self.class.can_edit? u, *args; end
	def self.can_destroy? u, *args; can_edit? u, *args; end
	def can_destroy? u, *args; can_edit? u, *args; end

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
  
end
