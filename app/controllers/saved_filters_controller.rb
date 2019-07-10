class SavedFiltersController < CrudController

	def index
		generic_filter_setup
		super
	end

end