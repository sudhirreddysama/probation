class TfViolationTypesController < TfRecordsController

	def index
		generic_filter_setup
		@cond << collection_conds({
			red_blue: 'tf_violation_types.red_blue',
		})		
		super
	end
	
end