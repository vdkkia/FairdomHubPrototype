class RepositoryStandard < ApplicationRecord
  has_many :sample_controlled_vocabs, inverse_of: :repository_standard, dependent: :destroy
  validates :title, presence: true
  validates :title, uniqueness: { scope: :group }

  accepts_nested_attributes_for :template_attributes, allow_destroy: true

  def can_delete?(user = User.current_user)
    return false if user.nil? || user.person.nil? 
    # return true if user.is_admin?
    contributor == user.person || projects.detect { |project| project.can_manage?(user) }.present?
    contributor && sample_types.empty?
  end

  def can_view?(user = User.current_user)
    (user && user.person && (user.person.projects & projects).any?)
  end

end
