class ChangeFlowchartsItemsType < ActiveRecord::Migration[5.2]
  def change
    change_column :flowcharts, :items, :text

  end
end
