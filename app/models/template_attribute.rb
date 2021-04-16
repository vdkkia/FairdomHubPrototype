class TemplateAttribute < ApplicationRecord
  belongs_to :sample_controlled_vocab
  belongs_to :sample_attribute_type
  belongs_to :repository_standard, inverse_of: :template_attributes
  validates :title, presence: true
end
