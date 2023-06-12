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
      indexes :title, type: "text" do
        indexes :title,     analyzer: "snowball"
        indexes :tokenized, analyzer: "simple"
      end
      indexes :created_at, type: "date"
      indexes :updated_at, type: "date"
      indexes :writers, type: "keyword"
      indexes :readers, type: "keyword"
    end
  end

  def as_indexed_json(options={})
    self.as_json.tap do |payload|
      payload["readers"] = readers
      payload["writers"] = writers
    end
  end

  def readers
    (permissions["reader"] || []).map { |u| u.to_permission_token }
  end

  def writers
    (permissions["writer"] || []).map { |u| u.to_permission_token }
  end

  def permissions
    @permissions ||= pg.entry_permissions(self).inject({}) do |all, (level, users)|
      all.merge(level => users.map(&:last))
    end
  end

  def pg
    @pg ||= PermissionGateway.new
  end

  def self.search(query, subject, options={})
    @search_definition = {
      query: {
        bool: {
          must: [
            auth_query(subject)
          ]
        }
      }, sort: {}, size: 50
    }

    unless query.blank?
      @search_definition[:query][:bool][:must] << {
        match: {
          title: query
        }
      }
    else
      @search_definition[:query][:bool][:must] = { match_all: {} }
    end

    if options[:desc] == "true"
      @search_definition[:sort]  = { updated_at: "desc" }
    else
      @search_definition[:sort]  = { updated_at: "asc" }
    end
    __elasticsearch__.search(@search_definition).records
  end

  def self.auth_query(subject)
    { 
      bool: {
        should: [
          {
            term: {
              readers: {
                value: subject.to_permission_token
              }
            }
          },
          {
            term: {
              writers: {
                value: subject.to_permission_token
              }
            }
          }
        ]
      }
    }
  end
end
