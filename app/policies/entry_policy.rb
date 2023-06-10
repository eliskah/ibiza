class EntryPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin? || permitted?(user: user, record: record, action: :view)
  end

  def create?
    user.admin?
  end

  def new?
    user.admin?
  end

  def update?
    user.admin? || permitted?(user: user, record: record, action: :edit)
  end

  def edit?
    user.admin? || permitted?(user: user, record: record, action: :edit)
  end

  def destroy?
    user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    attr_reader :user, :scope
    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      if user.admin?
        scope.all
      else
        permitted = scope.select(:id).to_a.select { |entry| permitted?(user: user, record: entry, action: :view)} 
        scope.where(id: permitted.pluck(:id))
      end
    end
  end
end
