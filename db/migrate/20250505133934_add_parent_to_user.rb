class AddParentToUser < ActiveRecord::Migration[7.2]
  def change
    add_reference :users, :parent, foreign_key: { to_table: :users }
  end
end
