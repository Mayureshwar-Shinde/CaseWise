class DisputeAnalysts::CasesController < ApplicationController
  before_action :authenticate_dispute_analyst!
  before_action :set_case, only: %i[show edit update]
  before_action :check_status, only: %i[edit update]

  def index
    @q = Case.where(assigned_to:  current_user).ransack(params[:q])
    @cases = @q.result(distinct: true)
    @cases = @cases.includes(:user).order('users.first_name') if params[:sort] == 'first_name'
    @cases = @cases.paginate(page: params[:page], per_page: 10).order(updated_at: :desc)
  end

  def show
    @note = @case.notes.new
    @notes = @case.notes.paginate(page: params[:page], per_page: 5).order(updated_at: :desc)
    @appointment = @case.appointments.new
    @communication = @case.communications.new
  end

  def edit
  end

  def update
    original_status = @case.status
    changes = {}
    if @case.update(case_params)
      changes[:status] = { before: original_status, after: @case.status } if original_status != @case.status
      # UserMailer.update_case(@case, changes, current_user).deliver_now unless changes.empty?
      redirect_to dispute_analysts_case_path(@case), notice: 'Case Updated successfully!'
    else
      render :edit, status: 422
    end
  end


  private

  def case_params
    params.require(:case).permit(:status)
  end

  def set_case
    @case = Case.find(params[:id])
  end

  def check_status
    return redirect_to dispute_analysts_case_path(@case), alert: 'Case closed!' if @case.status == 'closed'
  end

end
