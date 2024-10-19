class CaseManagers::CommunicationsController < ApplicationController
  before_action :authenticate_case_manager!
  before_action :set_case, only: %i[create index]

  def new
  end

  def create
  	@communication = @case.communications.new(communication_params)
  	if @communication.save
  	  if @communication.message_type == 'email'
        # UserMailer.new_email(@communication).deliver_now
        flash[:notice] = 'Email sent successfully!'
      else
        Twilio::SmsService.new.send_sms(@communication)
        flash[:notice] = 'SMS sent successfully!'
      end
  	else
  	  flash[:alert] = @communication.errors.full_messages.to_sentence
  	end
  	redirect_to case_managers_case_path(@case)
  end

  def index
    @q = @case.communications.ransack(params[:q])
    @communications = @q.result(distinct: true)
    if params[:sort] == 'from'
      @communications = @communications.includes(:from).order('users.first_name, users.last_name')
    elsif params[:sort] == 'to'
      @communications = @communications.includes(:to).order('users.first_name, users.last_name')
    end
    @communications = @communications.paginate(page: params[:page], per_page: 10).order(created_at: :desc)
  end

  private

  def set_case
  	@case = Case.find(params[:case_id])
  end

  def communication_params
  	params.require(:communication).permit(:case_id, :from_id, :to_id, :subject, :message, :message_type)
  end
end