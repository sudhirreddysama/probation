class UsersController < CrudController

	#before_filter :require_admin

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

	def autocomplete
		cond = search_filter(params.term, {
			'users.id' => :left,
			'users.username' => :like,
			'users.first_name' => :like,
			'users.last_name' => :like,
		})
		cond << 'users.active = 1'
		params.page = params.page ? params.page.to_i : 1
		objs = @model.where(get_where(cond)).order('users.first_name, users.last_name').paginate(page: params.page, per_page: 50)
		data = objs.map { |o|
			o.attributes.slice(*%w{id username first_name last_name})
		}
		render json: {data: data, page: params.page, per_page: 50, total: objs.total_entries, pages: objs.total_pages}
	end	
	
	def grid
		@col_skip = %w{password_digest}
		super
	end
	
end