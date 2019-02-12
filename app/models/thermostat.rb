class Thermostat < ApplicationRecord
  # associations
  has_many :readers, dependent: :destroy

  # validations
  validates :household_token, presence: true, uniqueness: true
  validates :location, presence: true
end
