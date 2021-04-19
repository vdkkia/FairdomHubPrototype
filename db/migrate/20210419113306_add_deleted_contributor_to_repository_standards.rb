class AddDeletedContributorToRepositoryStandards < ActiveRecord::Migration[5.2]
  def change
    add_column :repository_standards, :deleted_contributor, :string, default: nil
  end
end
