class Reader < ApplicationRecord
  belongs_to :thermostat

  validates :number, presence: true, numericality: { only_integer: true }
  validates :temperature, presence: true, numericality: { only_float: true }
  validates :humidity, presence: true, numericality: { only_float: true }
  validates :battery_charge, presence: true, numericality: { only_float: true }

  after_create :clear_redis

  def self.next_number
    Reader.connection.select_value("Select nextval('readers_id_seq')")
  end

  def clear_redis
    $redis.del self.number
  end
end
