class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |u|
      u.string :username
      u.string :email
      u.string :password_digest
      u.string :location
    end
  end
end
