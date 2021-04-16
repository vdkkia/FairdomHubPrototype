class AddSampleAttributeTypeIdToTemplateAttributes < ActiveRecord::Migration[5.2]
  def change
    add_column :template_attributes, :sample_attribute_type_id, :integer
  end
end
