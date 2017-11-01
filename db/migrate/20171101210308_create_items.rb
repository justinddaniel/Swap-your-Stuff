class CreateItems < ActiveRecord::Migration[5.1]
  def change
    create_table :items do |i|
      i.string :name
      i.string :description
      i.boolean :tradeable?
      i.string :condition
      i.float :asking_price
      i.string :keywords
      i.integer :user_id
    end
  end
end
