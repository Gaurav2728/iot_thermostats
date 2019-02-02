class ReadingsController < ApplicationController
  before_action :fetch_thermostat
  before_action :validate_presence, only: :create

  def index
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
end
