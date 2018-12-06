class Thermostat < ApplicationRecord
  has_many :readers, dependent: :destroy

  validates :household_token, presence: true, uniqueness: true
  validates :location, presence: true
end
