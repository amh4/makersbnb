# # frozen_string_literal: true

require "sinatra/base"
require "sinatra/reloader"
require "sinatra/activerecord"
require "bcrypt"
require "simple_calendar"
require_relative "lib/booking"
require_relative "lib/property"
require_relative "lib/user"

class MakersBnB < Sinatra::Base
  enable :sessions
  configure :development do
    register Sinatra::Reloader
  end

  use Rack::Session::Cookie, :key => "rack.session",
                             :path => "/",
                             :secret => ENV.fetch("SESSION_SECRET") { SecureRandom.hex(20) }

  get "/" do
    @a = logged_in
    @properties = Property.all
    return erb(:homepage)
  end

  get "/log-in" do
    return erb(:log_in)
  end

  get "/sign_up" do
    return erb(:sign_up)
  end

  post "/approve-reject/:id&:bool" do
    if params[:bool] == "true"
      booking = Booking.find(params[:id].to_i)
      booking.responded = true
      booking.save
    else
      booking = Booking.find(params[:id].to_i)
      booking.responded = false
      booking.save
    end
  end

  get "/account" do
    @requests = Booking.joins(:property).select("bookings.*, properties.*").where(["bookings.user_id = ? and bookings.responded = ?", session[:user_id], false])
    return erb(:account_page)
  end

  get "/bookings" do
    @properties = Booking.joins(:property).select("bookings.*, properties.*").where("user_id" => session[:user_id])
    erb(:bookings)
  end

  post "/log-in" do
    email = params[:email]
    password = params[:password]

    user = User.find_by(email: email)
    return erb(:log_in_error) if user.nil?
    if user.authenticate(password)
      session[:user_id] = user.id
      return erb(:logged_in)
    else
      status 400
      return erb(:log_in_error)
    end
  end

  post "/bookings" do
    return login_fail unless logged_in
    booking = Booking.create(user_id: session[:user_id], property_id: params[:property_id],
                             start_date: params[:start_date], end_date: params[:end_date], approved: false, responded: false)
  end

  get "/sign-up" do
    return erb(:sign_up)
  end

  post "/sign-up" do
    encrypted_password = BCrypt::Password.create(params[:password])
    @user = User.create(first_name: params[:first_name], last_name: params[:last_name], email: params[:email], password_digest: encrypted_password)
    if @user.errors.empty?
      return erb(:sign_up_confirmation)
    else
      status 400
      return erb(:sign_up_error)
    end
  end

  get "/property/:id" do
    @property = Property.find(params[:id])
    return erb(:book_a_space)
  end

  private

  def logged_in
    if session[:user_id] == nil
      return false
    else
      return true
    end
  end

  def login_fail
    status 400
    erb(:log_in_error)
  end
end
