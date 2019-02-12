IOT Thermostat
========

Many apartments have a central heating system and due to different room isolation properties it's not easy to keep the same temperature among them. To solve this problem we need to collect readings from IoT thermostats in each apartment so that we can adjust the temperature in all the apartments in real time.

The goal of this task is to build a basic web API for storing readings from IoT thermostats and reporting a simple statistics on them.


## Project Dependencies

### -- Ruby version
> Ruby 2.5.1+

### -- Rails Version
> Rails 5.2.2

### -- Database
> Postgresql 8+

### -- Redis
> Redis 4.0

## Project Setup
PostgreSQL and Redis should be running.

### Clone the git repo.
`$ git clone git@github.com:Gaurav2728/iot_thermostats.git`

### Enter into the project
`$ cd iot_thermostats`
###

### Install libraries
`$ bundle install`

### Seed development data
> Note: Change the `database.yml` file according to your system postgresql database settings.
```
$ rails db:setup
$ rails db:seed
```

### Start the rails server
`$ rails s`

### Start the sidekiq service (in another tab)
`$ bundle exec sidekiq`


## Welcome Page
![alt text](https://github.com/Gaurav2728/iot_thermostats/blob/master/public/welcome.png)



### -- Run the test suite
> rspec spec



# API


## 1. POST Reading:
> To create readings for a particular thermostat -

`curl -d "household_token=c4631897-3f2f-4c6f-8265-c55552b47d6f&temperature=45.4&humidity=1.1&battery_charge=12" http://localhost:3000/readings`

### Output
```
{"number":30}

  or

{"message":"Household token is invalid !"}
```

## 2. GET Reading:
> To get readings for a particular thermostat -

`http://localhost:3000/readings/1?household_token=ada08367-cc11-4ec7-9cfe-e0634d3c62d4`

  OR

```
curl -X GET -d "household_token=c4631897-3f2f-4c6f-8265-c55552b47d6f" http://localhost:3000/readings/:number

curl -X GET -d "household_token=c4631897-3f2f-4c6f-8265-c55552b47d6f" http://localhost:3000/readings/2
```

### Output
```
{
  "id": 2,
  "thermostat_id": 1,
  "number": 1,
  "temperature": 74.05,
  "humidity": 98.07,
  "battery_charge": 71.01,
  "created_at": "2019-03-27T13:03:45.295Z",
  "updated_at": "2019-03-27T13:03:45.295Z"
}
  OR

{"message":"Data not found for given Number"}
```

## 3. GET Stats:
> To get statistics of thermostats -

`http://localhost:3000/stats?household_token=ada08367-cc11-4ec7-9cfe-e0634d3c62d4`

 OR

`curl -X GET -d "household_token=c4631897-3f2f-4c6f-8265-c55552b47d6f" http://localhost:3000/stats`

### Output
```
{
"thermostat_data": [
  {
    "temperature": {
      "avg": 45.06,
      "min": 15.4,
      "max": 74.05
    }
  },
  {
  "humidity": {
    "avg": 29.84,
    "min": 1.1,
    "max": 98.07
    }
  },
  {
  "battery_charge": {
    "avg": 51.75,
    "min": 12,
    "max": 112
    }
  }
  ]
}
```

