class Reader < ApplicationRecord
  belongs_to :thermostat

  validates :number, presence: true, numericality: { only_integer: true }
  validates :temperature, presence: true, numericality: { only_float: true }
  validates :humidity, presence: true, numericality: { only_float: true }
  validates :battery_charge, presence: true, numericality: { only_float: true }

  def self.next_number
    Reader.connection.select_value("Select nextval('readers_id_seq')")
  end
end
