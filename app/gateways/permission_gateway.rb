class PermissionGateway
  def permitted?(user:, record:, action:)
    # Add real implementation
    user.id.even?
  end
end
