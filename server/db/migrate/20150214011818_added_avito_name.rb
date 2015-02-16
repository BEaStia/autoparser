class AddedAvitoName < ActiveRecord::Migration
  def change
    add_column :makers, :avitoname, :text
    add_column :models, :avitoname, :text
  end
end
