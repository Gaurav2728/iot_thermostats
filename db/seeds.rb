# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

MAX_RECORDS = 1..5

ActiveRecord::Base.transaction do
  # Create Thermostat
  MAX_RECORDS.each do
    Thermostat.create!(
      household_token: SecureRandom.uuid,
             location: Faker::Address.unique.city,
    )
  end

  # Create Readers
  thermostats = Thermostat.all
  thermostats.each do |thermostat|
    reader = thermostat.readers.build(
              number: Reader.next_number,
         temperature: Faker::Number.decimal(2),
            humidity: Faker::Number.decimal(2),
      battery_charge: Faker::Number.decimal(2)
    )
    reader.save!
  end
end
