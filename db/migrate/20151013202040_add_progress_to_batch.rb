class AddProgressToBatch < ActiveRecord::Migration
  def change
    add_column :batches, :progress, :integer, default: 0
  end
end
