class MessageType < ActiveRecord::Migration
    def change
      add_column :messages, :msg_type, :string
    end
end