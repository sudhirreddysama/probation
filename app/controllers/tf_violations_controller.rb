class TfViolationsController < TfRecordsController

	def index
		generic_filter_setup [
			['Operator Name', 'tf_facilities.operator_name'],
			['Food Stand', 'tf_facilities.food_stand'],
			['Event Name', 'tf_facilities.event_name'],
		]
		@cond << collection_conds({
			red_blue: 'tf_violations.red_blue',
			corrected: 'tf_violations.corrected',
			tf_event: 'tf_facilities.event_name'
		})
		@model = @model.eager_load(:tf_facility)
		super
	end
	
end