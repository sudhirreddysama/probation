class HsLedger < Record
	
	self.inheritance_column = nil
	
	# include DbChange::Track
	# include DbGroup::HasGroups
	# has_many :documents, as: :obj

	def label; "#{code_was} #{name_was}"; end
	
	#has_many :sales
	
	validates_presence_of :name, :code, :type
	
	CONFIGS = ['CC', 'Cash', 'Deferred', 'AR Default', 'GL Default']
	
	def self.gl_for_pay_method m
		m = 'Cash' if m == 'Check'
		find_by(config: m).code
	end
	
	def self.default_ar
		find_by(config: 'Default AR').code
	end
	
	def self.default_gl
		find_by(config: 'Default GL').code
	end
	
	has_many :shots, primary_key: :code, foreign_key: :ledger
	
	def sales
		Sale.where('? in (sales.debit_ledger, sales.credit_ledger)', code)
	end
	
	def sale_details
		SaleDetail.where('? in (sale_details.debit_ledger, sale_details.credit_ledger)', code)
	end
	
	scope :active, -> { where active: true }
	scope :active_or_id, -> (id) { id ? active.or(where id: id) : active }
	scope :default_order, -> { order code: :asc, name: :asc }
	
end