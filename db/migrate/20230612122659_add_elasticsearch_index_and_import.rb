class AddElasticsearchIndexAndImport < ActiveRecord::Migration[7.0]
  def up
    Entry.__elasticsearch__.create_index!
    Entry.import
  end

  def down
    Entry.__elasticsearch__.delete_index!
  end
end
