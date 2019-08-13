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
		DB.query('update qb_customers c set c.balance = (
			select sum(d.amount * if(d.type = "Payment", -1, 1)) from sale_details d
			where d.payment_id is null and d.amount != 0 and d.voided = 0 and d.qb_customer_id = c.id and d.type in ("Invoice", "Payment", "AR Refund")
		)')
	end

	
# 	def self.update_transaction_balance id = nil
# 		id = id.uniq if id.is_a?(Array)
# 		id = id[0] if id.is_a?(Array) && id.size == 1
# 		id = id.is_a?(Array) ? " in (#{id.map(&:to_i).join(',')})" : id ? " = #{id.to_i}" : nil
# 		DB.query('update sales t left join (
# 			select d.sale_id, sum(d.amount) amount from sale_details d 
# 			where d.type in ("Invoice", "Payment", "AR Refund") and d.payment_id is null and d.amount != 0' + (id ? ' and d.sale_id' + id : '') + ' group by d.sale_id
# 		) d on d.sale_id = t.id 
# 		set t.balance = d.amount
# 		where t.type in ("Invoice", "Payment", "AR Refund")' + (id ? ' and t.id' + id : ''))
# 	end
# 	
# 	def self.update_customer_balance id = nil
# 		id = id.uniq if id.is_a?(Array)
# 		id = id[0] if id.is_a?(Array) && id.size == 1
# 		id = id.is_a?(Array) ? " in (#{id.map(&:to_i).join(',')})" : id ? " = #{id.to_i}" : nil
# 		DB.query('update qb_customers c left join (
# 			select d.qb_customer_id, sum(if(d.type = "Invoice", 1, -1) * d.amount) amount from sale_details d
# 			where d.type in ("Invoice", "Payment", "AR Refund") and d.payment_id is null and d.amount != 0' + (id ? ' and d.qb_customer_id' + id : '') + ' group by d.qb_customer_id
# 		) d on d.qb_customer_id = c.id
# 		set c.balance = d.amount
# 		' + (id ? ' where c.id' + id : ''))
# 		
# 		
# 		# TO DO: This is too slow. Abandon balance_total field?
# 		#DB.query('update qb_customers c' + (id ? '' : ' left') + ' join (
# 		#	select c.id, ifnull(c.balance, 0) + sum(c2.balance) balance from qb_customers c 
# 		#	join qb_customers c2 on c2.balance != 0 and c2.full_id_path like concat(c.full_id_path, ":", "%%")
# 		#	' + (id ? 'join qb_customers c3 on c3.id' + id + ' and c3.full_id_path like concat(c.full_id_path, ":", "%%")' : '') + '
# 		#	group by c.id
# 		#) b on b.id = c.id
# 		#set c.balance_total = b.balance')
# 		
# 		
# 	end
	
# 	def self.update_account_balances
# 		DB.query('update qb_accounts a 
# 			left join (select sum(amount) amt, qb_account_id id from sale_details group by qb_account_id) d1 on d1.id = a.id
# 			left join (select sum(amount) amt, qb_account2_id id from sale_details group by qb_account2_id) d2 on d2.id = a.id
# 			set a.balance = ifnull(d2.amt, 0) - ifnull(d1.amt, 0)'
# 		)
# 		DB.query('update qb_accounts a left
# 			join (
# 				select a.id, a.balance + sum(a2.balance) amt from qb_accounts a join qb_accounts a2 on a2.balance != 0 and a2.full_id_path like concat(a.full_id_path, ":", "%%") group by a.id
# 			) b on b.id = a.id
# 			set a.balance_total = b.amt'
# 		)
# 	end
# 	
# 	def self.update_transaction_balances
# 		DB.query('update sales t
# 			left join (
# 				select sum(amount * if(type = "Payment", -1, 1)) amt, d.sale_id
# 				from sale_details d where d.payment_id is null and d.type in("Invoice", "Payment") group by d.sale_id
# 			) d on d.sale_id = t.id
# 			set t.balance = ifnull(d.amt, 0)'
# 		)
# 	end
# 	
# 	def self.update_customer_balances
# 		DB.query('update qb_customers c
# 			left join (
# 				select sum(amount * if(type = "Payment", -1, 1)) amt, d.qb_customer_id
# 				from sale_details d where d.payment_id is null and d.type in ("Invoice", "Payment") group by d.qb_customer_id
# 			) d on d.qb_customer_id = c.id
# 			set c.balance = ifnull(d.amt, 0)'
# 		)
# 
# 	end

end