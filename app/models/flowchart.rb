class Flowchart < ApplicationRecord
    belongs_to :study
    has_many :streams
end
