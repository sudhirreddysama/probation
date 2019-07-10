class VeRecord < ApplicationRecord
  self.abstract_class = true
  
  def self.can_view? u, *args
  	u.ve_user? || u.ve_admin?
  end
  
  def self.can_create? u, *args
  	u.ve_admin?
  end

end