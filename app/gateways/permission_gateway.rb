class PermissionGateway
  attr_reader :authz
  def initialize
    @authz = AuthzedClient.new
  end

  def permitted?(user:, record:, action:)
    authz.check(resource: entry(record.id), subject: user(user.id), permission: action)
  end

  def permit_write!(user:, entry:)
    authz.write([[entry(entry.id), "writer", user(user.id)]])
  end

  def permit_read!(user:, entry:)
    authz.write([[entry(entry.id), "reader", user(user.id)]])
  end

  private

    def user(id)
      AuthzedClient.object(type: "user", id: id)
    end

    def entry(id)
      AuthzedClient.object(type: "entry", id: id)
    end
end
