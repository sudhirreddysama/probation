class QbCustomer < QbRecord
	
	def self.can_create? u, *args
		u.qb_user? || u.qb_admin?
	end

	self.inheritance_column = nil

	# include DbChange::Track
	# include DbGroup::HasGroups
	# has_many :documents, as: :obj

	def label; name_was; end
	
	include HasPath
	
	validates_presence_of :division, :name
	validates_presence_of :email, if: :deliver_via_email_or_both?
	
	def deliver_via_email_or_both?; contact_via.in?(['Email', 'Both']); end
	
	def self.types
		where('qb_customers.type is not null').order('type').group('type').pluck(:type)
	end
	
	has_many :qb_transactions
	has_many :qb_transaction_details
	
	def qb_customers
		QbCustomer.where 'id_path like ?', full_id_path.to_s + '%'
	end
	
	def bill_to j = "\n"
		[bill_to1, bill_to2, bill_to3, bill_to4, bill_to5].reject(&:blank?) * j
	end
	
	def ship_to j = "\n"
		[ship_to1, ship_to2, ship_to3, ship_to4, ship_to5].reject(&:blank?) * j
	end
	
	def facility_address j = "\n"
		[facility_address1, facility_address2, facility_address3, facility_address4].reject(&:blank?) * j
	end
	
	belongs_to :qb_ledger, foreign_key: :ledger, primary_key: :code
	
	def build_transaction typ = nil
		o = qb_transactions.build({type: typ, division: division})
		o.set_defaults_for_type
		if o.payment? || o.ar_refund?
			o.amount = balance.to_f * (o.ar_refund? ? -1 : 1)
			o.payment_for_ids = qb_transaction_details.needs_payment.pluck(:id)
		end
		return o
	end
	
end