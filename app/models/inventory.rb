class Inventory < ApplicationRecord
	validates_presence_of :item_dec
	validates_uniqueness_of :item_dec, message: "has already been taken ", if: :uniqe_item_dec
	validates_format_of :incident_rep, :with => /\A[0-9][0-9_]*\Z/, message: "Please enter numbers only", if: :is_non_seriral?

	def is_non_seriral?
		bool = false
		if(nsn_in_inventory)
		  	bool = (nsn_in_inventory.to_i >= 0)
		else
			bool = nsn_in_inventory
		end
		!!bool
	end

	def uniqe_item_dec
		if(expendable == "true")
			false
		else
			if(nsn_in_inventory)
				Inventory.where(item_dec: item_dec, status: "Inventory").where("nsn_in_inventory is not null").length > 0
			else
				Inventory.where(item_dec: item_dec, status: "Inventory").where("nsn_in_inventory is null").length > 0
			end
		end
	end
end
