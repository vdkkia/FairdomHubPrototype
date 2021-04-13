class AddPolicyIdToRepositoryStandards < ActiveRecord::Migration[5.2]
  def change
    add_column :repository_standards, :policy_id, :integer
  end
end
