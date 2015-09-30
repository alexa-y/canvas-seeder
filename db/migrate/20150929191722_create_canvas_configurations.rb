class CreateCanvasConfigurations < ActiveRecord::Migration
  def change
    create_table :canvas_configurations do |t|
      t.string :name
      t.string :domain
      t.string :access_token

      t.timestamps null: false
    end
  end
end
