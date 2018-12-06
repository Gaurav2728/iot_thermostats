class Reader < ApplicationRecord
  belongs_to :thermostat

  validates :number, presence: true, numericality: { only_integer: true }
  validates :temperature, presence: true, numericality: { only_float: true }
  validates :humidity, presence: true, numericality: { only_float: true }
  validates :battery_charge, presence: true, numericality: { only_float: true }
end
