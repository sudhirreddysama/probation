class User < ApplicationRecord

	include DbChange::Track

	LEVELS = [
		['User', 'user'],
		['Admin', 'admin']
	]

	validates_presence_of :username, :first_name, :last_name, :email, :level
	validates_format_of :password, with: /\A(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9]).{6,50}\z/, allow_blank: true, message: 'must be at least 6 characters and contain at least one uppercase and lowercase letter, number, and special character (#%$@*...)'
	validates_uniqueness_of :username, allow_blank: true
	
	has_secure_password validations: false
	validates_confirmation_of :password, allow_blank: true
	validate { |o|
		o.errors.add(:password, :blank) if !auth_ldap && !o.password_digest.present?
	}
	
	def self.can_create? u, *args; u.admin?; end
	def can_clone? u, *args; can_edit? u, *args; end
	def can_edit? u, *args; self.class.can_create? u, *args; end
	def can_destroy? u, *args; can_edit? u, *args; end	
	
	def label; username_was; end
	
	def name; "#{first_name} #{last_name}"; end
	
	def initials; (first_name.to_s[0] + last_name.to_s[0]).upcase; end
	
	def email_with_name; "#{name} <#{email}>"; end
	
	def level; super.try(:inquiry); end

	def self.authenticate u, p
		return nil if u.blank? || p.blank?
		user = find_by(username: u)
		if user
			if user.auth_ldap
				return user if authenticate_ldap(u, p)
			else
				return user.try(:authenticate, p)
			end	
		end
		return nil
	end
	
	def self.authenticate_by_activation_key id, id2
		return nil if id.blank? || id2.blank?
		u = where(active: true, id: id, activation_key: id2).take
		return nil if !u
		u.update_attribute :activation_key, nil
		return u
	end
	
	def self.find_lost_account lost
		return nil if lost.blank?
		u = where('active = 1 and (username = ? or email = ?)', lost, lost).take
		return nil if !u
		u.update_attribute(:activation_key, Array.new(10) { rand(9).to_s }.join)
		return u
	end
	
	def admin?; level.admin?; end
	
	attr :force_new_password, true
	def handle_before_save
		if force_new_password && force_new_password != '0'
			self.password_set_at = nil
		elsif password_digest_changed?
			self.password_set_at = Time.now
		end
	end
	before_save :handle_before_save
	
	def self.authenticate_ldap u, p
		return nil if u.blank? || p.blank?
		conn = Net::LDAP.new(host: LDAP_HOST, port: LDAP_PORT, base: LDAP_BASE, auth: {username: "#{u}#{LDAP_DOMAIN}", password: p, method: :simple})
		if conn.bind
			results = conn.search filter: Net::LDAP::Filter.equals('samaccountname', u)			
			return results.first
		end
		return nil
	rescue Net::LDAP::LdapError => e # Connection errors
		return false
	end	
	
	def self.lookup_ldap u
		return [] if u.blank?
		conn = Net::LDAP.new(host: LDAP_HOST, port: LDAP_PORT, base: LDAP_BASE, auth: {username: LDAP_USER, password: LDAP_PASS, method: :simple})
		if conn.bind
			return conn.search({filter: 
				Net::LDAP::Filter.equals('objectCategory', 'person') & 
				Net::LDAP::Filter.equals('objectClass', 'user') & 
				(Net::LDAP::Filter.begins('samaccountname', u) | Net::LDAP::Filter.contains('cn', u))
			})
		end
		return []
	rescue  Net::LDAP::LdapError => e # Connection errors
		return []
	end
	
	def self.lookup_ou_users_ldap ou
		conn = Net::LDAP.new(host: LDAP_HOST, port: LDAP_PORT, base: "OU=#{ou},#{LDAP_BASE}", auth: {username: LDAP_USER, password: LDAP_PASS, method: :simple})
		if conn.bind
			return conn.search({filter:
				Net::LDAP::Filter.equals('objectCategory', 'person') & 
				Net::LDAP::Filter.equals('objectClass', 'user')
			})
		end
		return []
	rescue  Net::LDAP::LdapError => e # Connection errors
		return []
	end
	
end