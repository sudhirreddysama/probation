class QbLateFeesController < QbRecordsController
	
	def index
		generic_filter_setup
		@cond << collection_conds({
			division: "#{@model.table_name}.division",
		})
		super
	end
	
end