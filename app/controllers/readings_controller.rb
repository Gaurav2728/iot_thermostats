class ReadingsController < ApplicationController
  before_action :fetch_thermostat, except: :index
  before_action :validate_presence, only: :create

  def index
    @thermostat = Thermostat.all
  end

  def create
    $redis.set(@number, params)
    ReadingWorker.perform_async(@number, @thermostat.id, @temperature, @humidity, @battery_charge)
    render json: {number: @number}
  end

  def show
    reader = $redis.get(params[:id]) || Reader.find_by(number: params[:id])
    render json: { message: "Data not found for given Number" } and return if !reader
    render json: reader
  end

  def stats
    db_data = data_store
    redis_data = redis_store

    output = []
    if redis_data.empty?
      output = db_data
    elsif db_data.empty?
      output = redis_data
    else
      db_data.each_with_index do |val,i|
        val.each do |k,value|
          avg_val = (value["avg"].to_f + redis_data[i][k]["avg"].to_f) / 2
          min_val = [value["min"].to_f, redis_data[i][k]["min"].to_f].min
          max_val = [value["max"].to_f, redis_data[i][k]["max"].to_f].max
          output << {k => {avg: avg_val, min: min_val, max: max_val} }
        end
      end
    end
    render json: { thermostat_data: output }
  end

  private
    def fetch_thermostat
      token = params[:household_token]
      render json: { message: 'Please provide household token.' }, status: 401 and return if !token
      @thermostat = Thermostat.find_by(household_token: token)
      render json: { message: 'Household token is invalid !' }, status: 401 and return if !@thermostat
    end

    def validate_presence
      if %w(temperature humidity battery_charge).all? {|key| params[key].present?}
        @temperature = params[:temperature]
        @humidity = params[:humidity]
        @battery_charge = params[:battery_charge]
        @number = Reader.next_number
        reader = Reader.new(permit_params.merge!(thermostat_id: @thermostat.id, number: @number))
        render json: { errors: reader.errors } and return if reader.invalid?
      else
        render json: { message: 'Please check paramaters and values should be present.' }, status: 400
      end
    end


    def permit_params
      params.permit(:temperature, :humidity, :battery_charge)
    end

    def data_store
      data = []
      aggregation = @thermostat.readers.pluck('Avg(temperature)', 'Min(temperature)', 'Max(temperature)', 'Avg(humidity)', 'Min(humidity)', 'Max(humidity)', 'Avg(battery_charge)', 'Min(battery_charge)', 'Max(battery_charge)').first
      unless aggregation.empty?
        data << { temperature: {"avg" => aggregation[0].round(2), "min" => aggregation[1], "max" => aggregation[2]}}
        data << { humidity: {"avg" => aggregation[3].round(2), "min" => aggregation[4], "max" => aggregation[5]}}
        data << { battery_charge: {"avg" => aggregation[6].round(2), "min" => aggregation[7], "max" => aggregation[8]}}
      end
      return data
    end

    def redis_store
      redis_data = []
      cache_result = []
      redis_keys = $redis.keys
      unless redis_keys.empty?
        redis_keys.each do |k|
          reading = eval($redis.get(k))
          next if !reading["household_token"].eql?(params[:household_token])
          redis_data << { temperature: reading["temperature"], humidity: reading["humidity"],  battery_charge: reading["battery_charge"] }
        end
      end

      unless redis_data.blank?
        thermostat_attr = ["temperature", "humidity", "battery_charge"]
        avg_data = avg_data(thermostat_attr, redis_data)
        min_data = min_data(thermostat_attr, redis_data)
        max_data = max_data(thermostat_attr, redis_data)
        cache_result << { temperature: {"avg" => avg_data[0].round(2), "min" => min_data[0], "max" => max_data[0]}}
        cache_result << { humidity: {"avg" => avg_data[1].round(2), "min" => min_data[1], "max" => max_data[1]}}
        cache_result << { battery_charge: {"avg" => avg_data[2].round(2), "min" => min_data[2], "max" => max_data[2]}}
      end
      return cache_result
    end

    def avg_data(thermostat_attr, redis_data)
      thermostat_attr.map do |type|
        redis_data.map { |x| x[type].to_f }.sum / redis_data.size
      end
    end

    def min_data(thermostat_attr, redis_data)
      thermostat_attr.map do |type|
        redis_data.min_by { |h| h[type].to_i }[type]
      end
    end

    def max_data(thermostat_attr, redis_data)
      thermostat_attr.map do |type|
        redis_data.max_by { |h| h[type].to_i }[type]
      end
    end
end
