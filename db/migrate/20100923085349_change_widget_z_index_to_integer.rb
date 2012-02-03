class ChangeWidgetZIndexToInteger < ActiveRecord::Migration
  def self.up
    change_table :widgets do |t|
      t.remove :zindex
      t.integer :zindex
    end
  end

  def self.down
    change_table :widgets do |t|
      t.remove :zindex
      t.string :zindex
    end
  end
end
