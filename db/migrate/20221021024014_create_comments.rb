class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.integer :tention_id
      t.string :description
      t.string :title
      t.timestamps
    end
  end
end
