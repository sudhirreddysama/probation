class FdEstablishment < ApplicationRecord

	include DbChange::Track
	
	has_many :documents, as: :obj
	has_many :fd_activities
	belongs_to :fd_fee_schedule, foreign_key: 'capacity_rate', primary_key: 'fee_code'
	belongs_to :qb_customer
	
	validates_presence_of :facility_name
	
	def label; estab_name_was; end
	
	MOBILE_TYPES = [
		['PUSH CART', 'CART'],
		['COMMISARY', 'COMM'],
		['MOBILE', 'MOBI'],
	]
	
	STATUSES = [
		['1 Active', '1'], 
		['2 Out Of Business', '2'], 
		['3 Pending', '3']	
	]
	
	def handle_before_save
		if gaz_number.blank? && !estab_type_code.blank? && !prefixgaz.blank?
			num = DB.query(
				'select max(cast(substr(left(gaz_number, length(gaz_number) - ?), ?) as unsigned)) v from fd_establishments where gaz_number like ?', 
				estab_type_code.to_s.length, prefixgaz.to_s.length + 1, "#{prefixgaz}%#{estab_type_code}"
			).first.try(:[], 'v').to_i + 1
			self.gaz_number = "#{prefixgaz}#{'%03d' % num}#{estab_type_code}"
		end
	end
	before_save :handle_before_save

end