class CreateBatches < ActiveRecord::Migration
  def change
    create_table :batches do |t|
      t.references :canvas_configuration, index: true, foreign_key: true
      t.text :params
      t.text :output

      t.timestamps null: false
    end
  end
end
