# This migration comes from biovision_base_engine (originally 20170301000002)
class CreateMetricValues < ActiveRecord::Migration[5.1]
  def up
    unless MetricValue.table_exists?
      create_table :metric_values do |t|
        t.references :metric, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
        t.timestamp :time, null: false
        t.integer :quantity, null: false, default: 1
      end

      execute "create index metric_values_day_idx on metric_values using btree (date_trunc('day', time));"
    end
  end

  def down
    if MetricValue.table_exists?
      drop_table :metric_values
    end
  end
end
