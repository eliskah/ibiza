class Entry < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  # TBD: This should be async
  after_commit lambda { Indexer.new.perform(:index,  self.class.to_s, self.id) }, on: :create
  after_commit lambda { Indexer.new.perform(:update, self.class.to_s, self.id) }, on: :update
  after_commit lambda { Indexer.new.perform(:delete, self.class.to_s, self.id) }, on: :destroy
  after_touch  lambda { Indexer.new.perform(:update, self.class.to_s, self.id) }

  settings index: { number_of_shards: 1, number_of_replicas: 0 } do
    mapping do
      indexes :title, type: 'text' do
        indexes :title,     analyzer: 'snowball'
        indexes :tokenized, analyzer: 'simple'
      end
      indexes :created_at, type: 'date'
      indexes :updated_at, type: 'date'
      indexes :writers, type: 'keyword'
      indexes :readers, type: 'keyword'
    end
  end

  def as_indexed_json(options={})
    self.as_json.tap do |payload|
      payload['readers'] = readers
      payload['writers'] = writers
    end
  end

  def readers
    (permissions["reader"] || []).map { |s| to_permission_token(s.last) }
  end

  def writers
    (permissions["writer"] || []).map { |s| to_permission_token(s.last) }
  end

  def permissions
    @permissions ||= pg.entry_permissions(self)
  end

  def pg
    @pg ||= PermissionGateway.new
  end

  def to_permission_token(subject)
    "#{subject.class.name}##{subject.id}"
  end
end
