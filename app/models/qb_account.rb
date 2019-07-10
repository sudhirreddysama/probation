class QbAccount < QbRecord

	self.inheritance_column = nil

	include DbChange::Track
	include DbGroup::HasGroups
	has_many :documents, as: :obj

	def label; name_was; end
	
	include HasPath
	
	has_many :qb_transactions
	has_many :qb_item_prices
	
	validates_presence_of :name, :division
	
	TYPES = [
		'Accounts Payable',
		'Accounts Receivable',
		'Cost of Goods Sold',
		'Equity',
		'Expense',
		'Fixed Asset',
		'Income',
		'Non-Posting',
		'Other Current Asset',
		'Other Current Liability',
		'Other Expense'
	]
	def self.types; TYPES; end
	
# 	def sync_path
# 		super
# 		if parent
# 			self.account_type = parent.account_type
# 			self.division = parent.division
# 		end
# 	end
	
	def next_invoice_no year = nil
		return nil if invoice_prefix.blank?
		year ||= Time.now.year
		pre = "#{invoice_prefix}#{year}-"
		n = DB.query('select max(1 + substring_index(t.num, "-", -1)) n from qb_transactions t where t.num like ?', "#{pre}%").first.n.to_i
		return pre + ('%04i' % n)
	end
	
end