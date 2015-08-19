class CustomButtonImportService
  def import_from_yaml(custom_button_yaml)
    custom_buttons = YAML.load(custom_button_yaml)

    custom_buttons.each do |custom_button|
      new_or_existing_custom_button = CustomButton.where(:guid => custom_button["guid"]).first_or_create
      new_or_existing_custom_button.update_attributes(custom_button)
    end
  end
end
