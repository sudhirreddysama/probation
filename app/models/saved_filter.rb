class SavedFilter < ApplicationRecord

	include DbChange::Track
	
	self.inheritance_column = nil
	
	belongs_to :user
	
	serialize :data, JSON
	
	validates_presence_of :name
	
	def label; name_was; end
	
	def self.can_create? *args; false; end
	def can_edit? u, *args; u.admin?; end
	
	def self.scope_for_class_context c; where(:type => c.to_s.pluralize.underscore); end
	
end