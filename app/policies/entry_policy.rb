class EntryPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin? || user.has_read_permission?(record)
  end

  def create?
    user.admin? || user.has_write_permission?(record)
  end

  def new?
    user.admin? || user.has_write_permission?(record)
  end

  def update?
    user.admin? || user.has_write_permission?(record)
  end

  def edit?
    user.admin? || user.has_write_permission?(record)
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
