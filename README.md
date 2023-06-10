# README

This is a demo app showing how to implement a rails app with role and attribute based permission system.

* Ruby version

2.7.5

* System dependencies

Running Spice DB locally. To install, follow this guide:

https://authzed.com/docs/spicedb/installing#docker

* Configuration

First, run this snippet:

```ruby
require 'authzed'

schema = <<~SCHEMA
    definition user {}
    definition entry {
        relation writer: user
        relation reader: user

        permission edit = writer
        permission view = reader + edit
    }
    SCHEMA

client = Authzed::Api::V1::Client.new(
    target: 'localhost:50051',
    interceptors: [Authzed::GrpcUtil::BearerToken.new(token: 'somerandomkeyhere')],
    credentials: :this_channel_is_insecure,
)

resp = client.schema_service.write_schema(
  Authzed::Api::V1::WriteSchemaRequest.new(schema: schema)
)
```

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
