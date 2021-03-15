class RenameRepositoryStandardsTitleAndGroupTag < ActiveRecord::Migration[5.2]
  def change
    rename_column :repository_standards, :title, :name
    rename_column :repository_standards, :group_tag, :group
    remove_index :repository_standards, name: 'index_repository_standards_title_group_tag'
    add_index :repository_standards, [:name, :group], name: 'index_repository_standards_name_group'
  end
end
