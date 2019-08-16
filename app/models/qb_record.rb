class QbRecord < ApplicationRecord
	self.abstract_class = true
  
  def self.can_view? u, *args
  	u.qb_user? || u.qb_admin? || true
  end
  
  def self.can_create? u, *args
  	u.qb_admin? || true
  end

	module HasPath
		
		extend ActiveSupport::Concern
		
		def id_path_parts
			id_path.to_s.split ':'
		end
		
		def path_parts
			path.to_s.split ':'
		end
		
		def full_id_path_parts
			full_id_path.split ':'
		end
		
		def full_path_parts
			full_path.split ':'
		end
		
		def depth
			full_path.to_s.count(':')
		end
 	
 		def sync_paths
			self.path = parent ? parent.full_path : nil
			self.id_path = parent ? parent.full_id_path : nil
			self.full_path = parent ? "#{path}:#{name}" : name
			self.full_id_path = parent ? "#{id_path}:#{id}" : id
 		end
 	
 		def parent_not_self
 			errors.add :parent_id, '^Cannot select self as parent' if parent_id == id
 		end
 		
		included {
			validates_format_of :name, without: /:/, message: "^Name cannot contain \":\""
			validate :parent_not_self, if: :id
			belongs_to :parent, class_name: self.to_s
			before_validation { |o|
				o.sync_paths if o.parent_id_changed? || o.name_changed?
			}
			after_create { |o|
				o.sync_paths
				o.update_column :full_id_path, full_id_path
			}
		}
	end
	
	def self.update_all_balances
		update_customer_balance
		update_transaction_balance
	end

	def self.update_transaction_balance
		DB.query('update sales t set t.balance = (
			select sum(d.amount * if(d.type = "Payment", -1, 1)) from sale_details d
			where d.payment_id is null and d.amount != 0 and d.sale_id = t.id
		) where t.type in ("Invoice", "Payment", "AR Refund")')
	end
	
	def self.update_customer_balance
		DB.query('update customers c set c.balance = (
			select sum(d.amount * if(d.type = "Payment", -1, 1)) from sale_details d
			where d.payment_id is null and d.amount != 0 and d.voided = 0 and d.customer_id = c.id and d.type in ("Invoice", "Payment", "AR Refund")
		)')
	end
	
end