require "spec_helper"

describe CustomButtonImportService do
  let(:custom_button_import_service) { described_class.new }

  describe "#import_from_yaml" do
    context "when the list of buttons to import from the yaml includes an existing button" do
      let(:custom_button_yaml) { "---\n- guid: lol\n  description: description\n  name: not name anymore" }

      before do
        CustomButton.create!(:guid => "lol", :name => "name", :description => "description", :applies_to_class => "test")
      end

      it "overwrites the existing button" do
        custom_button_import_service.import_from_yaml(custom_button_yaml)
        expect(CustomButton.where(:guid => "lol").first.name).to eq("not name anymore")
      end
    end

    context "when the list of buttons to import from the yaml does not include an existing button" do
      let(:custom_button_yaml) do
        "---\n- guid: lol\n  description: description\n  name: not name anymore\n  applies_to_class: test"
      end

      it "creates a new button" do
        custom_button_import_service.import_from_yaml(custom_button_yaml)
        expect(CustomButton.where(:guid => "lol").first).to_not be_nil
      end
    end
  end
end
