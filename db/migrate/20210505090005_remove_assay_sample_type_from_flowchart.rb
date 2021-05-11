class RemoveAssaySampleTypeFromFlowchart < ActiveRecord::Migration[5.2]
  def change
    remove_column :flowcharts, :assay_sample_type, :string
  end
end
