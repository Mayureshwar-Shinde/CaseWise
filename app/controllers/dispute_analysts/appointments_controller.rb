class DisputeAnalysts::AppointmentsController < ApplicationController
  before_action :authenticate_dispute_analyst!
  before_action :set_case, except: :my_appointments
  before_action :set_status_color, only: %i[index my_appointments]
  helper_method :sort_direction

  def index
    @q = @case.appointments.ransack(params[:q])
    @appointments = @q.result(distinct: true)
    if params[:sort] == 'case_manager'
      @appointments = @appointments.includes(:case_manager).order('users.first_name, users.last_name')
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
    redirect_to dispute_analysts_case_path(@case)
  end

  def complete
    @appointment = Appointment.find(params[:id])
    if @appointment.datetime < DateTime.current
      @appointment.status = 'completed'
      @appointment.save(validate: false)
      flash[:notice] = 'Appointment marked as completed.'
    else
      flash[:alert] = "You can only mark an appointment as completed after the scheduled time."
    end
    redirect_to dispute_analysts_case_path(@case)
  end

  def my_appointments
    @q = Appointment.where(dispute_analyst: current_user).ransack(params[:q])
    @appointments = @q.result(distinct: true)
    if params[:sort] == 'case_manager'
      @appointments = @appointments.includes(:case_manager).order('users.first_name, users.last_name')
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
      redirect_to dispute_analysts_case_path(@case), alert: "Case closed!"
    end
  end

  def appointment_params
  	params.require(:appointment).permit(:case_id, :case_manager_id, :dispute_analyst_id, :date, :time, :status)
  end

end
