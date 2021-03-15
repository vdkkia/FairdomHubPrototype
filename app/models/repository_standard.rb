class RepositoryStandard < ApplicationRecord
  has_many :sample_controlled_vocabs, inverse_of: :repository_standard, dependent: :destroy
  validates :name, presence: true
  validates :name, uniqueness: { scope: :group }
end
