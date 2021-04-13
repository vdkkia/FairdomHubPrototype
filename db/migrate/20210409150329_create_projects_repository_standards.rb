class CreateProjectsRepositoryStandards < ActiveRecord::Migration[5.2]
  def change
    create_table :projects_repository_standards do |t|
      t.references :repository_standard
      t.references :project
    end
  end
end