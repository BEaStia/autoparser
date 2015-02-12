class CreateModels < ActiveRecord::Migration
  def change
    create_table :models do |t|
      t.belongs_to :maker, index: true
      t.text :model
      t.integer :autoru
    end
  end
end
