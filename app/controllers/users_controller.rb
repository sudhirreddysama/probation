class UsersController < CrudController

	before_filter :require_admin

	def index
		generic_filter_setup
		@cond << 'users.active = 1' if @filter.show == 'active'
		@cond << 'users.active = 0' if @filter.show == 'inactive'	
		super
	end
	
	def ldap_autocomplete
		results = User.lookup_ldap params.term
		results.map! { |r| {
			first_name: r[:givenname][0],
			last_name: r[:sn][0],
			username: r[:samaccountname][0],
			title: r[:title][0],
			phone: r[:telephonenumber][0]
		}}
		render json: results.to_json
	end
	
end