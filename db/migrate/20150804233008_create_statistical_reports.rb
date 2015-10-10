class CreateStatisticalReports < ActiveRecord::Migration
  def change
    create_table :statistical_reports do |t|
      t.belongs_to :user, index: true
      t.string :statement
      t.string :description
      t.string :result
      t.timestamps null: false
    end
  end
end
