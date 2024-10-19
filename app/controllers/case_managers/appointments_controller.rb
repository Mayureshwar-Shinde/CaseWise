class CaseManagers::AppointmentsController < ApplicationController
  before_action :authenticate_case_manager!
  before_action :set_case, except: :my_appointments
  before_action :set_appointment, only: %i[edit update complete]
  before_action :set_status_color, only: %i[index my_appointments]
  
  helper_method :sort_direction

  def index
    @q = @case.appointments.ransack(params[:q])
    @appointments = @q.result(distinct: true)
    if params[:sort] == 'case_manager'
      @appointments = @appointments.includes(:case_manager).order('users.first_name, users.last_name')
    elsif params[:sort] == 'dispute_analyst'
      @appointments = @appointments.includes(:dispute_analyst).order('users.first_name, users.last_name')
    end
    @appointments = @appointments.paginate(page: params[:page], per_page: 10).order(date: :desc, time: :desc)
  end

  def new
  end

  def create
    @appointment = Appointment.new(appointment_params)
    if @appointment.save
      flash[:notice] = "Appointment booked successfully!"
      # UserMailer.new_appointment(@appointment, current_user).deliver_now
    else
      flash[:alert] = @appointment.errors.full_messages.to_sentence
    end
    redirect_to case_managers_case_path(@case)
  end

  def edit
    unless @appointment.case_manager == current_user
      redirect_to case_managers_case_path(@case), alert: 'You can only edit your appointments!'
    end
    if @appointment.datetime <= DateTime.current
      redirect_to case_managers_case_path(@case), alert: 'Cannot edit past Appointment!'
    end
  end

  def update
    original_date = @appointment.date.strftime("%d %b %y")
    original_time = @appointment.time.strftime("%l:%M%P")
    original_status = @appointment.status.capitalize

  	if @appointment.update(appointment_params)
      changes = {}
      changes[:date] = { before: original_date, after: @appointment.date.strftime("%d %b %y") } if original_date != @appointment.date.strftime("%d %b %y")
      changes[:time] = { before: original_time, after: @appointment.time.strftime("%l:%M%P") } if original_time != @appointment.time.strftime("%l:%M%P")
      changes[:status] = { before: original_status, after: @appointment.status.capitalize } if original_status != @appointment.status.capitalize
      # UserMailer.update_appointment(@appointment, changes).deliver_now unless changes.empty?
  	  redirect_to case_managers_case_path(@case), notice: "Appointment updated successfully!"
  	else
  	  render :edit, status: 422
  	end
  end

  def complete
    if @appointment.datetime < DateTime.current
      @appointment.status = 'completed'
      @appointment.save(validate: false)
      flash[:notice] = 'Appointment marked as completed.'
    else
      flash[:alert] = "You can only mark an appointment as completed after the scheduled time."
    end
    redirect_to case_managers_case_path(@case)
  end

  def my_appointments
    @q = Appointment.where(case_manager: current_user).ransack(params[:q])
    @appointments = @q.result(distinct: true)
    if params[:sort] == 'case_manager'
      @appointments = @appointments.includes(:case_manager).order('users.first_name, users.last_name')
    elsif params[:sort] == 'dispute_analyst'
      @appointments = @appointments.includes(:dispute_analyst).order('users.first_name, users.last_name')
    elsif params[:sort] == 'case_number'
      @appointments = @appointments.includes(:case).order("cases.case_number #{sort_direction}")
    end
    @appointments = @appointments.paginate(page: params[:page], per_page: 10).order(date: :desc, time: :desc)
  end

  private

  def set_status_color
    @color = {
      'pending' => 'text-warning',
      'cancelled' => 'text-danger',
      'scheduled' => 'text-secondary',
      'completed' => 'text-success'
    }
  end

  def sort_direction
    params[:direction] == 'asc' ? 'desc' : 'asc'
  end

  def set_case
  	@case = Case.find(params[:case_id])
    if @case.status == 'closed'
      redirect_to case_managers_case_path(@case), alert: "Case closed!"
    end
  end

  def set_appointment
  	@appointment = Appointment.find(params[:id])
  end

  def appointment_params
  	params.require(:appointment).permit(:case_id, :case_manager_id, :dispute_analyst_id, :date, :time, :status)
  end

end
