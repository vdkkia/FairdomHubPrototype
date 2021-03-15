class AddVersionToSampleControlledVocabs < ActiveRecord::Migration[5.2]
  def change
    add_column :sample_controlled_vocabs, :version, :string
  end
end
