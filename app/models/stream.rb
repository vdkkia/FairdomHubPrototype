class Stream < ApplicationRecord
    belongs_to :flowchart
    has_many :stream_items
    has_many :sample_types, through: :stream_items
end
