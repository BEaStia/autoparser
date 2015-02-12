class CreateMakers < ActiveRecord::Migration
  def change
    create_table :makers do |t|
      t.text :maker
      t.text :autoruname
      t.integer :autoru
    end
  end
end
