class PayeezyPost < ApplicationRecord

	def self.can_create? u, *arg; false; end
	
	if Rails.env.development?
		
		# https://demo.globalgatewaye4.firstdata.com
		# monroe495 <-- old
		# monroe194
		# ad.IS.34.test4
		
		API_URL = 'https://api.demo.globalgatewaye4.firstdata.com/transaction/v24' #v19?
		#GATEWAY_ID = 'PA0472-58'
		#PASSWORD = 'puleAkiPbucRNio65kuk1TYHrKAmvE1h'
		#KEY_ID = '586124'
		#HMAC_KEY = '_HTQa~KN8ja55H4Qo5bucQ1ml9lWy6rW'
		GATEWAY_ID = 'OB0846-57'
		PASSWORD = 'Xeqf8R8Bvk282RAgP4SuAAscOUKZGlq7'
		KEY_ID = '635276'
		HMAC_KEY = 'Vx47blmDxfUsx5I8hB8LlYxIic~QrZdh'
	else
		API_URL = 'https://api.globalgatewaye4.firstdata.com/transaction/v24' #v19?
		#GATEWAY_ID = 'D23414-01'
		GATEWAY_ID = 'H27820-43'
		#PASSWORD = 'tsC7ECmsagyewIX9peyCVSdOyRHJdVv2'
		PASSWORD = 'KUq6OI2Wax2a6fJqI5GfWPNHItyD3Rx5'
		#KEY_ID = '354230'
		KEY_ID = '619445'
		#HMAC_KEY = 'KJsFaEXTQT23T5lH92xamtRlx7GnFZTg'
		HMAC_KEY = 'mICSgQh1FXjiCH6pd8S0V8c5XRFjfW4m'
	end
	
	CARD_TYPES = %w{Visa Mastercard Discover}
	
	TYPES = {
		'00' => 'Purchase',
		'01' => 'Pre-Authorization',
		'04' => 'Refund',
		'13' => 'Void',
		'32' => 'Tagged Completion',
		'33' => 'Tagged Void',
		'34' => 'Tagged Refund'
	}
	
	def type_name; TYPES[transaction_type]; end
	def type_and_name; "#{transaction_type} #{type_name}".strip; end
	
	def prev_type_name; TYPES[prev_type]; end
	def prev_type_and_name; "#{prev_type} #{prev_type_name}".strip; end
	
	def label; [created_at.dt, TYPES[transaction_type], card_last4] * ' '; end
	
	belongs_to :previous, class_name: 'PayeezyPost'
	has_many :next_posts, class_name: 'PayeezyPost', foreign_key: 'previous_id'
	
	attr_accessor :card_code_present, :card_number, :card_code
	
	def card_number= v
		@card_number = v
		self.card_last4 = v.to_s[-4, 4]
		self.card_type = case v.to_s[0, 1]
			when '5', '2'; 'Mastercard'
			when '4'; 'Visa'
			when '6'; 'Discover'
		end
	end
	
	def build_next attr = {}
		p = PayeezyPost.new attr
		p.set_previous self
		return p
	end
	
	def set_previous v
		self.previous = v
		self.card_type = v.card_type
		self.card_name = v.card_name
		self.card_date = v.card_date
		self.card_last4 = v.card_last4
		self.prev_type = v.transaction_type
		self.prev_authorization_num = v.authorization_num
		self.prev_transaction_tag = v.transaction_tag
		self.prev_transarmor_token = v.transarmor_token
		return v
	end
	
	def purchase
		do_post('00') { |t| set_card_data t }
	end
	
	def refund
		do_post('04') { |t| set_card_data t }
	end	
	
	def preauthorize
		do_post('01') { |t| set_card_data t }
	end

	def tagged_completion
		do_post('32') { |t| set_tag_amount_and_num t }
	end	
	
	def tagged_void
		do_post('33') { |t| set_tag_amount_and_num t }
	end
	
	def tagged_refund
		do_post('34') { |t| set_tag_amount_and_num t }
	end
	
	def formatted_dollar_amount
		'%.2f' % dollar_amount.to_f
	end
	
	def set_card_data t
		t.CardType card_type if !card_type.blank?
		t.DollarAmount formatted_dollar_amount
		t.Expiry_Date card_date
		t.CardHoldersName card_name
		t.CVD_Presence_Ind(card_code_present ? '1' : '0')
		t.CVDCode card_code if !card_code.blank?
		t.Address { |a|
			a.Address1 address if !address.blank?
			a.Address2 address2 if !address2.blank?
			a.City city if !city.blank?
			a.State state if !state.blank?
			a.Zip zip_code if !zip_code.blank?
			a.CountryCode country_code if !country_code.blank?
			a.PhoneNumber phone if !phone.blank?
			a.PhoneType phone_type if !phone_type.blank?
		}
		card_number_or_transarmor_token t
	end
	
	def set_tag_amount_and_num t
		t.Transaction_Tag prev_transaction_tag
		t.DollarAmount formatted_dollar_amount
		t.Authorization_Num prev_authorization_num
	end
	
	def card_number_or_transarmor_token(t)
		if card_number.blank?
			t.TransarmorToken prev_transarmor_token
		else
			t.Card_Number card_number
		end
	end
	
	def error_message
		return nil if transaction_approved
		err = nil
		err = exact_message if exact_code.to_i != 0
		err = bank_message if err.blank?
		err = response_body if err.blank?
		err = 'Credit card payment failed.' if err.blank?
		return err
	end
	
	def do_post type_code
		self.transaction_type = type_code
		method = 'POST'
		content_type = 'application/xml'
		uri = URI.parse API_URL
		self.request_datetime = Time.now
		time = request_datetime.utc.strftime '%Y-%m-%dT%H:%M:%SZ'
		builder = Nokogiri::XML::Builder.new { |xml|
			xml.Transaction { |t|
				t.ExactID GATEWAY_ID
				t.Password PASSWORD
				t.Transaction_Type type_code
				yield t
			}
		}
		content = builder.to_xml
		hashed_content = Digest::SHA1.hexdigest content
		data = method + "\n" + content_type + "\n" + hashed_content + "\n" + time + "\n" + uri.request_uri
		hmac = Base64.encode64(OpenSSL::HMAC.digest('sha1', HMAC_KEY, data))
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		request = Net::HTTP::Post.new(uri.request_uri)
		request['X-GGE4-DATE'] = time
		request['X-GGE4-CONTENT-SHA1'] = hashed_content
		request['Content-Length'] = content.size
		request['Content-Type'] = content_type
		request['Authorization'] = 'GGE4_API ' + KEY_ID + ':' + hmac.strip
		response = http.request(request, content)
		self.request_body = content.sub(/<Card_Number>\d+(\d{4})</, '<Card_Number>************\1<').sub(/<CVDCode>\d+</, '<CVDCode>***<')
		self.response_code = response.code
		self.response_body = response.body.to_s.sub(/<CVDCode>\d+</, '<CVDCode>***<')
		if response_code.to_s[0, 1] == '2'
			xml = Nokogiri::Slop(response.body)
			r = xml.TransactionResult
			self.receipt = r.CTR.text
			self.authorization_num = r.Authorization_Num.text
			self.transaction_tag = r.Transaction_Tag.text
			a = r.Transaction_Approved.text
			self.transaction_approved = (a == 'true' || a == '1')
			self.transarmor_token = r.TransarmorToken.text
			self.bank_code = r.Bank_Resp_Code.text
			self.bank_message = r.Bank_Message.text
			self.exact_code = r.EXact_Resp_Code.text
			self.exact_message = r.EXact_Message.text
		end
		# Up to controlling code to save since we're probably in the middle of a commit that might be rolled back.
		return transaction_approved
	end
	
	has_one :qb_transaction
	has_one :voided_qb_transaction, foreign_key: :voided_payeezy_post_id, class_name: 'QbTransaction'
	def source
		qb_transaction || voided_qb_transaction
	end
	
	# One time fix to re-set card types from payeezy response that were not properly stored from public orders side due to a (fixed) bug.
	def self.fix_card_types
		PayeezyPost.find(:all, :conditions => 'card_type is null and response_body like "<?xml version=%"').each { |pay|
			match = /<CardType>([^<]*)<\/CardType>/.match pay.response_body.to_s
			if match && match[1]
				pay.update_attribute :card_type, match[1]
			end
		}
		nil
	end
	
	# One time fix to nuke the security codes
	def self.redact_security_codes
		PayeezyPost.find(:all, :conditions => 'response_body like "%<CVDCode>%"').each { |pay|
			pay.response_body = pay.response_body.sub(/<CVDCode>\d+</, '<CVDCode>***<')
			pay.save
		}
	end

end