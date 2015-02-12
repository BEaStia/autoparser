class AddAutoruName < ActiveRecord::Migration
  def change
    add_column :models, :autoruname, :text
  end
end
