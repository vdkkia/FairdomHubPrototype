class ContributorIdToRepositoryStandards < ActiveRecord::Migration[5.2]
  def change
    add_column :repository_standards, :contributor_id, :integer
  end
end
