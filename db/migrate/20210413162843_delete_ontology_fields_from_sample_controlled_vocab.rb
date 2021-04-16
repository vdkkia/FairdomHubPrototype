class DeleteOntologyFieldsFromSampleControlledVocab < ActiveRecord::Migration[5.2]
  def change
    remove_column :sample_controlled_vocabs, :repository_standard_id, :integer
    remove_column :sample_controlled_vocabs, :required, :boolean
    remove_column :sample_controlled_vocabs, :short_name, :string
    remove_column :sample_controlled_vocabs, :version, :string
  end
end
