# Be sure to restart your server when you modify this file.

#Rails.application.config.session_store :cookie_store, key: "_ehpermits2#{Rails.env.development? ? 'dev' : ''}_session"

Rails.application.config.session_store :active_record_store, key: "_ehpermits2#{Rails.env.development? ? 'dev' : ''}_session"
