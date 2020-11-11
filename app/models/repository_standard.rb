class RepositoryStandard < ApplicationRecord
  acts_as_authorized
  
  has_many :sample_controlled_vocabs, inverse_of: :repository_standard, dependent: :destroy
  validates :title, presence: true
  validates :title, uniqueness: { scope: :group_tag }
end
