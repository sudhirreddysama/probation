class QbTemplate < QbRecord

	has_many :qb_transactions
	
	def label; name_was; end
	
	validates_presence_of :name, :address
	
	belongs_to :late_shot, class_name: 'Shot'
	
	DEFAULTS = {
		label_head_name: 'Project',
		label_head_fac: 'Facility Address',
		show_head_name: false,
		show_head_fac: false,
		label_foot_name: 'Facility',
		label_foot_num: 'FAC #',
		show_foot_name: false,
		show_foot_num: false,
		label_item_info: 'Info',
		label_item_name: 'Item',
		label_item_desc: 'Description',
		label_item_quantity: 'Quantity',
		label_item_price: 'Price',
		label_item_amount: 'Amount',
		show_item_info: false,
		show_item_name: true,
		show_item_desc: true,
		show_item_quantity: true,
		show_item_price: true,
		show_item_amount: true,
		checks_to: 'Monroe County'
	}
	
	def self.get_tpl t
		d = DEFAULTS
		return d if !t
		return {
			label_head_name: t.label_head_name.presence || d.label_head_name,
			label_head_fac: t.label_head_fac.presence || d.label_head_fac,
			show_head_name: t&.show_head_name,
			show_head_fac: t&.show_head_fac,
			label_foot_name: t&.label_foot_name.presence || d.label_foot_name,
			label_foot_num: t&.label_foot_num.presence || d.label_foot_num,
			show_foot_name: t&.show_foot_name,
			show_foot_num: t&.show_foot_num,
			label_item_info: t&.label_item_info.presence || d.label_item_info,
			label_item_name: t&.label_item_name.presence || d.label_item_name,
			label_item_desc: t&.label_item_desc.presence || d.label_item_desc,
			label_item_quantity: t&.label_item_quantity.presence || d.label_item_quantity,
			label_item_price: t&.label_item_price.presence || d.label_item_price,
			label_item_amount: t&.label_item_amount.presence || d.label_item_amount,
			show_item_info: t&.show_item_info,
			show_item_name: t&.show_item_name,
			show_item_desc: t&.show_item_desc,
			show_item_quantity: t&.show_item_quantity,
			show_item_price: t&.show_item_price,
			show_item_amount: t&.show_item_amount,
			checks_to: t&.checks_to.presence || d.checks_to,
			footer_text: t&.footer_text
		}
	end
	
	def address_line
		address.to_s.gsub /[\n\r]+/, ', '
	end
	
	belongs_to :qb_cost_center, foreign_key: :cost_center, primary_key: :code
	
	belongs_to :late_qb_cost_center, class_name: 'QbCostCenter', foreign_key: :late_cost_center, primary_key: :code
	belongs_to :late_qb_credit_ledger, class_name: 'QbLedger', foreign_key: :late_credit_ledger, primary_key: :code
	belongs_to :late_shot, class_name: 'Shot', foreign_key: :late_shot_id

	scope :active, -> { where active: true }
	scope :active_or_id, -> (id) { id ? active.or(where id: id) : active }
	scope :default_order, -> { order name: :asc }
	
	def handle_before_save
		self.late_item_name = late_shot&.full_path if late_shot_id_changed?
	end
	before_save :handle_before_save
	
	def num typ
		return nil if typ.blank?
		attributes["#{typ.to_s.downcase.gsub(' ', '')}_num"]
	end
	
end