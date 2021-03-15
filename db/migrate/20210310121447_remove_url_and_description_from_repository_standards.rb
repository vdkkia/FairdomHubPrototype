class RemoveUrlAndDescriptionFromRepositoryStandards < ActiveRecord::Migration[5.2]
  def change
    remove_column :repository_standards, :url
    remove_column :repository_standards, :description
    remove_column :repository_standards, :repo_type
  end
end