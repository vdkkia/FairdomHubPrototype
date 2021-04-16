class AddDescriptionToRepositoryStandards < ActiveRecord::Migration[5.2]
  def change
    add_column :repository_standards, :description, :text
  end
end
