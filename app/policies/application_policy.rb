# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  delegate :permitted?, to: :permission_gateway

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def permission_gateway
    ::PermissionGateway.new
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    delegate :permitted?, to: :permission_gateway

    def resolve
      raise NotImplementedError, "You must define #resolve in #{self.class}"
    end

    def permission_gateway
      ::PermissionGateway.new
    end

    private

    attr_reader :user, :scope
  end
end
