require "spec_helper"

describe CustomButtonSerializer do
  let(:custom_button_serializer) { described_class.new }

  describe "#serialize_to_yaml" do
    let(:custom_button) do
      CustomButton.new(
        :guid              => "guid",
        :applies_to_exp    => "exp",
        :wait_for_complete => true,
        :visibility        => {:roles => %w(_ALL_)},
        :applies_to_id     => 123,
        :description       => "description",
        :name              => "name",
        :applies_to_class  => "class",
        :options           => {:button_image => 2, :display => true},
        :userid            => "admin"
      )
    end

    let(:expected_data) do
      [{
        "guid"              => "guid",
        "description"       => "description",
        "applies_to_class"  => "class",
        "applies_to_exp"    => "exp",
        "options"           => {:button_image => 2, :display => true},
        "userid"            => "admin",
        "wait_for_complete" => true,
        "name"              => "name",
        "visibility"        => {:roles => %w(_ALL_)},
        "applies_to_id"     => 123
      }]
    end

    it "serializes the custom buttons" do
      expect(YAML.load(custom_button_serializer.serialize_to_yaml([custom_button]))).to eq(expected_data)
    end
  end
end
