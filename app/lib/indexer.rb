class Indexer
  Client = Elasticsearch::Client.new host: (ENV['ELASTICSEARCH_URL'] || 'http://localhost:9200')

  def perform(operation, klass, record_id, options={})
    Rails.logger.debug [operation, "#{klass}##{record_id} #{options.inspect}"]

    case operation.to_s
      when /index|update/
        record = klass.constantize.find(record_id)
        record.__elasticsearch__.client = Client
        record.__elasticsearch__.__send__ "#{operation}_document"
      when /delete/
        Client.delete index: klass.constantize.index_name, type: klass.constantize.document_type, id: record_id
      else raise ArgumentError, "Unknown operation '#{operation}'"
    end
  end
end
