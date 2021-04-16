class RemoveAttributeTypeFromTemplateAttributes < ActiveRecord::Migration[5.2]
  def change
    remove_column :template_attributes, :attribute_type
  end
end
