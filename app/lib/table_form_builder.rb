class TableFormBuilder < ActionView::Helpers::FormBuilder
  
  def tr_text_field method, options = {}
  	tr_field(options) { text_field(method, options) }
  end
  
  def tr_password_field method, options = {}
  	tr_field(options) { password_field(method, options) }
  end
  
  def tr_text_area method, options = {}
  	tr_field(options) { text_area(method, options) }
  end
  
  def tr_select method, choices = nil, options = {}, html_options = {}, &block
  	tr_field(options) { select(method, choices, options, html_options, &block) }
  end
  
  def tr_radio_button method, tag_value, options = {}
  	tr_field(options) { radio_button(method, tag_value, options) }
  end
  
  def tr_check_box method, options = {}, checked_value = '1', unchecked_value = '0'
  	text = options.delete :text
  	tr_field(options) {
			field = check_box(method, options, checked_value, unchecked_value)
			if text
				field = ('<label>' + field.to_s + ' ' + text.to_s + '</label>').html_safe
			end
			field
		}
  end
  
  def tr_collection_radio_buttons method, collection, value_method, text_method, options = {}, html_options = {}, &block
  	tr_field(options) { collection_radio_buttons(method, collection, value_method, text_method, options, html_options, &block) }
  end
  
  def tr_button value = nil, options = {}, &block
  	tr_field(options) { button(value, options, &block) }
  end
  
  def tr_field options
  	label = options.delete :label
  	tr = options.delete :tr
  	after = options.delete :after
  	req = options.delete :req
  	if label.empty?
  		label = '&nbsp;'
  	end
  	@template.content_tag(:tr,
  		@template.content_tag(:th, 
  			(label + (req ? ' <span class="req">*</span>' : '')).html_safe
  		) + 
  		@template.content_tag(:td,
  			yield + after.to_s.html_safe
  		),
  		tr
  	)
  end
  
end