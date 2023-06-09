class EntryPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin? || permitted?(user: user, record: record, action: :show)
  end

  def create?
    user.admin?
  end

  def new?
    user.admin?
  end

  def update?
    user.admin? || permitted?(user: user, record: record, action: :write)
  end

  def edit?
    user.admin? || permitted?(user: user, record: record, action: :write)
  end

  def destroy?
    user.admin?
  end

  class Scope
    attr_reader :user, :scope
    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      if user.admin?
        scope.all
      else
        # TBD
        scope.none
      end
    end
  end
end
