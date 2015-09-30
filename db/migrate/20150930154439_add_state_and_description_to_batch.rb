class AddStateAndDescriptionToBatch < ActiveRecord::Migration
  def change
    add_column :batches, :state, :string
    add_column :batches, :description, :string
  end
end
