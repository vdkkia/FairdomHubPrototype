class AddRepositoryStandardIdToSampleType < ActiveRecord::Migration[5.2]
  def change
    add_column :sample_types, :repository_standard_id, :integer
  end
end
