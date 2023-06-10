require "authzed"

class AuthzedClient
  def initialize
    @_client = Authzed::Api::V1::Client.new(
      target: "localhost:50051",
      interceptors: [Authzed::GrpcUtil::BearerToken.new(token: "somerandomkeyhere")],
      credentials: :this_channel_is_insecure
    )
  end

  def write(relationships)
    updates = relationships.map do |(resource, relation, subject)|
      update(resource: resource, relation: relation, subject: subject)
    end
    request = Authzed::Api::V1::WriteRelationshipsRequest.new(updates: updates)
    response = @_client.permissions_service.write_relationships(request)
    response.written_at.token
  end

  PERMITTED = Authzed::Api::V1::CheckPermissionResponse::Permissionship::PERMISSIONSHIP_HAS_PERMISSION
  def check(resource:, permission:, subject:)
    request = Authzed::Api::V1::CheckPermissionRequest.new(
      resource: resource,
      permission: permission,
      subject: Authzed::Api::V1::SubjectReference.new(object: subject),
    )
    response = @_client.permissions_service.check_permission(request)
    Authzed::Api::V1::CheckPermissionResponse::Permissionship.resolve(response.permissionship) == PERMITTED
  end

  def update(resource:, relation:, subject:)
    Authzed::Api::V1::RelationshipUpdate.new(
      operation: Authzed::Api::V1::RelationshipUpdate::Operation::OPERATION_CREATE,
      relationship: Authzed::Api::V1::Relationship.new(
        resource: resource,
        relation: relation,
        subject: Authzed::Api::V1::SubjectReference.new(object: subject)
      )
    )
  end

  def self.object(type:, id:)
    Authzed::Api::V1::ObjectReference.new(object_type: type, object_id: id.to_s)
  end
end
