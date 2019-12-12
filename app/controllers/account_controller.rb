class AccountController < ApplicationController
	
	skip_before_filter :require_login, only: [:index, :recover]
	layout 'login', except: [:edit, :login_edit]
	
	def index
		return if !request.post?
		if @login = params[:login]
			u = User.authenticate @login[:username], @login[:password]
			if u
				session[:current_user_id] = u.id
				if u.password_set_at.nil? && !u.auth_ldap
					redirect_to({db: nil, db_id: nil, action: :login_edit}, notice: 'You have successfully logged in. Please update your password.')
				else
					redirect_after_login 'You have successfully logged in.'
				end
				u.update_attribute :last_login_at, Time.now
			else
				@errors = ['Invalid login']
			end
		elsif @lost = params[:lost]
			u = User.find_lost_account @lost[:username]
			if u
				if u.auth_ldap
					@errors = ['Please use your network/PC username and password to login.']
				else
					Notifier.account_recovery(u, url_for(action: :recover, id: u.id, id2: u.activation_key)).deliver_now
					redirect_to({}, notice: 'An account recovery email has been sent to your email address. Click the link in the email to sign in to your account.')
				end
			else
				@errors = ['Username/email not found.']
			end
		end
	end
	
	def recover
		u = User.authenticate_by_activation_key params[:id], params[:id2]
		if u
			session[:current_user_id] = u.id
			u.update_attribute :last_login_at, Time.now
			redirect_to({db: nil, db_id: nil, action: :login_edit}, notice: 'Account recovery successfull. You have been automatically logged in. Please update your account with a new password.')
			return
		end
		redirect_to({db: nil, db_id: nil, action: :index}, flash: {errors: ['Invalid recovery key']})
	end
	
	def logout
		reset_session
		redirect_to({db: nil, db_id: nil, controller: :account, action: :index}, notice: 'You have been logged out.')
	end
	
	def edit
		@obj = @current_user
		if request.post? and @obj.update params[:obj]
			if params.action == 'login_edit'
				redirect_after_login 'Your account has been updated.'
			else
				redirect_to({}, notice: 'Your account has been updated.')
			end
		else
			render action: :edit
		end
	end	
	
	def login_edit
		edit
	end
	
	private 
	
	def redirect_after_login notice = nil
		if session[:after_login]
			redirect_to session[:after_login], notice: notice
			session[:after_login] = nil
		else
			redirect_to root_url, notice: notice
		end
	end

end