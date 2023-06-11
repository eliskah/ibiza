class PermissionGateway
  attr_reader :authz
  def initialize
    @authz = AuthzedClient.new
  end

  def permitted?(user:, record:, action:)
    authz.check(resource: entry(record.id), subject: user(user.id), permission: action)
  end

  def entry_permissions(entry)
    authz.resource_permissions(entry).map do |p|
      parse_permission(p.to_h)
    end.group_by(&:first)
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

    def parse_permission(permission)
      subject = permission[:relationship][:subject][:object]
      subject_klass = subject[:object_type].titleize.constantize
      [
        permission[:relationship][:relation],
        subject_klass.find_by(id: subject[:object_id])
      ]
    end
end
