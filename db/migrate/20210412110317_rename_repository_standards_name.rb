class RenameRepositoryStandardsName < ActiveRecord::Migration[5.2]
  def self.up
    rename_column :repository_standards, :name, :title
  end

  def self.down
    rename_column :repository_standards, :title, :name
  end
end
