# Load the Rails application.
require_relative 'application'

if Rails.env.production?
	Rails.application.config.middleware.use ExceptionNotification::Rack, :email => {
		:email_prefix => "[EHPERMITS]",
		:sender_address => %{"EHPermits" <noreply@monroecounty.gov>},
		:exception_recipients => %w{jessesternberg@monroecounty.gov}
	}
end

# Initialize the Rails application.
Rails.application.initialize!

Rails.application.config.active_record.belongs_to_required_by_default = false

if Rails.env.development?
	require 'core_ext'
end

APP_HUMAN_NAME = 'Health Clinic'
ROOT_PATH = Rails.env.development? ? '/dev/' : '/'
APP_HOST = 'ehpermits.monroecounty.gov'
ROOT_URL = 'https://' + APP_HOST + ROOT_PATH

Rails.application.routes.default_url_options[:host] = APP_HOST

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  html = Nokogiri::HTML::DocumentFragment.parse(html_tag)
	html.children.add_class 'error'
	html.to_s.html_safe
end

LDAP_HOST = '10.100.224.38'
LDAP_PORT = 389
LDAP_BASE = 'ou=mc,dc=mc,dc=ad,dc=monroecounty,dc=gov'
LDAP_USER = 'ldaplook'
LDAP_PASS = 'ldapl00k'
LDAP_DOMAIN = '@monroecounty.gov'

require 'net/http'
require 'mail'

QB_DIVS = ['Food', 'Eng', 'TR', 'ME']

DEPT = 'Department of Public Health'