# README

This is a demo app showing how to implement a rails app with role and attribute based permission system.

## Business logic:
* There are admins and users
* Admins can do anything
* Users can only see content where they are readers or writers
* Users can only edit/destroy content where they are writers

## Ruby version

2.7.5

## System dependencies

Running Spice DB locally. To install, follow this guide, don't change anything regarding credentials:

https://authzed.com/docs/spicedb/installing#docker

Running Elasticsearch locally. Follow these steps:

https://www.elastic.co/guide/en/elasticsearch/reference/7.17/docker.html


## Configuration

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

Then setup the app with `bin/setup` and run `rails server`. See the `db/seeds.rb` file to see the initial content.
