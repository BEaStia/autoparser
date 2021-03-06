class CreateAuto < ActiveRecord::Migration
  def change
    create_table :autos do |t|
      t.text :maker
      t.text :model
      t.integer :year
      t.integer :price
      t.text :town
      t.integer :milage
      t.text :short_description
      t.text :uid
      t.boolean :new
      t.boolean :active
      t.datetime :posted_at
      t.text :phone
      t.text :description
      t.text :color
      t.float :volume
      t.integer :hp
      t.text :wd
      t.text :fuel
      t.text :body
      t.text :steering_wheel
      t.text :gearbox
      t.timestamps

    end
  end

  def down
    drop_table :autos
  end
end
