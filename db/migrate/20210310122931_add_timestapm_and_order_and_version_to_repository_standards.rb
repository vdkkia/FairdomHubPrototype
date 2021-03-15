class AddTimestapmAndOrderAndVersionToRepositoryStandards < ActiveRecord::Migration[5.2]
  def change
    add_column :repository_standards, :group_order, :integer
    add_column :repository_standards, :temporary_name, :string
    add_column :repository_standards, :template_version, :string
    add_column :repository_standards, :isa_config, :string
    add_column :repository_standards, :isa_measurement_type, :string
    add_column :repository_standards, :isa_technology_type, :string
    add_column :repository_standards, :isa_protocol_type, :string
    add_column :repository_standards, :repo_schema_id, :string
    add_column :repository_standards, :organism, :string
    add_column :repository_standards, :level, :string
    add_timestamps(:repository_standards)
  end
end
