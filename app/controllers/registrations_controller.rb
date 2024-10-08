class RegistrationsController < ApplicationController
  def index
    @registrations = Registration.all
  end

  def show
    @registration = Registration.find(params[:id])
  end

  def new
    @registration = Registration.new
  end

  def create
    @registration = Registration.new(registration_params)
    if @registration.save
      redirect_to registrations_url
    else
      render :new
    end
  end

  def edit
    @registration = Registration.find(params[:id])
  end

  def update
    @registration = Registration.find(params[:id])
    if @registration.update(registration_params)
      redirect_to registrations_url
    else
      render :edit
    end
  end

  def confirm_destroy
    @registration = Registration.find(params[:id])
    render turbo_stream: turbo_stream.replace(
      "modal",
      partial: "delete_modal",
      locals: { registration: @registration }
    )
  end

  def destroy
    @registration = Registration.find(params[:id])
    @registration.destroy

    respond_to do |format|
      format.turbo_stream { redirect_to registrations_url, notice: 'Registration was successfully deleted.' }
      format.html { redirect_to registrations_url, notice: 'Registration was successfully deleted.' }
    end
  end

  private

  def registration_params
    params.require(:registration).permit(:first_name, :last_name, :birthday, :gender, :email, :phone_number, :subject)
  end
end