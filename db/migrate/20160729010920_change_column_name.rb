class ChangeColumnName < ActiveRecord::Migration
  def change
    rename_column :messages, :type, :msg_type
  end
end
