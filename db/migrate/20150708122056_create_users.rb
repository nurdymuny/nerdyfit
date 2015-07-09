class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :provider, null: false
      t.string :userid, null: false
      t.string :name
      t.string :location
      t.string :image_url
      t.string :url

      t.timestamps null: false
    end

    add_index :users, :provider
    add_index :users, :userid
    add_index :users, [:provider, :userid], unique: true
  end
end
