class CreateTemplateAttributes < ActiveRecord::Migration[5.2]
  def change
    create_table :template_attributes do |t|
      t.string :title
      t.string :short_name
      t.string :attribute_type
      t.boolean :required, :default => false
      t.string :ontology_version
      t.text :description
      t.integer :repository_standard_id
      t.integer :sample_controlled_vocab_id

      t.timestamps
    end
    add_index :template_attributes, [:repository_standard_id, :title], name: 'index_repository_standard_id_asset_id_title'
  end
end