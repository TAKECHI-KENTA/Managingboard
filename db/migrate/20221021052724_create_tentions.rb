class CreateTentions < ActiveRecord::Migration[5.2]
  def change
    create_table :tentions do |t|
      t.string :examination
      t.timestamps
    end
  end
end
