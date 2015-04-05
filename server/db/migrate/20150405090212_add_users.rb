class AddUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.text :name
      t.text :password
      t.integer :requests
      t.integer :demo
      t.timestamps
    end
    User.create! name: "admin", password: "password", requests: 2, demo: 0
  end
end
