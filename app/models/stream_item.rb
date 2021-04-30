class StreamItem < ApplicationRecord
    belongs_to :stream
    belongs_to :sample_type
end
