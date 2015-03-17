class CreateTiles < ActiveRecord::Migration
  def change
    create_table :tiles do |t|
      t.string :title
      t.text :text

      t.timestamps null: false
    end
  end
end
