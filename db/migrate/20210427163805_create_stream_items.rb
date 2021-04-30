class CreateStreamItems < ActiveRecord::Migration[5.2]
  def change
    create_table :stream_items do |t|
      t.references :stream
      t.references :sample_type
      t.integer :position
    end
  end
end
