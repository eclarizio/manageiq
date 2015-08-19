class CustomButtonSerializer < Serializer
  EXCLUDED_ATTRIBUTES = %w(created_on id updated_on)

  def serialize_to_yaml(custom_buttons)
    serialize_buttons(custom_buttons).to_yaml
  end

  private

  def serialize_buttons(custom_buttons)
    custom_buttons.collect do |custom_button|
      included_attributes(custom_button.attributes)
    end
  end
end
