class CaseManagers::CasesController < ApplicationController
  before_action :authenticate_case_manager!
  before_action :set_case, only: %i[show edit update]
  before_action :set_dispute_anaysts, only: %i[edit update]

  def new
    @case = current_user.cases.new
  end

  def create
    @case = current_user.cases.new(case_params)
    if @case.save
      redirect_to case_managers_cases_path, notice: 'Case created successfully'
    else
      render :new, status: 422
    end
  end

  def index
    @q = Case.all.ransack(params[:q])
    @cases = @q.result(distinct: true)

    if params[:sort] == 'first_name'
      @cases = @cases.includes(:user).order('users.first_name, users.last_name')
    elsif params[:sort] == 'assigned_to'
      @cases = @cases.includes(:assigned_to).order('users.first_name, users.last_name')
    end

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
    original_title = @case.title
    original_description = @case.description
    original_assigned_to = @case.assigned_to.full_name if @case.assigned_to
    original_status = @case.status

    if @case.update(case_params)
      changes = {}
      changes[:title] = { before: original_title, after: @case.title } if original_title != @case.title
      changes[:description] = { before: original_description, after: @case.description } if original_description != @case.description
      changes[:assigned_to] = { before: original_assigned_to, after: @case.assigned_to.full_name } if @case.assigned_to && original_assigned_to != @case.assigned_to.full_name
      changes[:status] = { before: original_status, after: @case.status } if original_status != @case.status
      # UserMailer.update_case(@case, changes, current_user).deliver_now unless changes.empty?
      redirect_to case_managers_case_path(@case), notice: 'Case Updated successfully!'
    else
      render :edit, status: 422
    end
  end

  private

  def case_params
    params.require(:case).permit(:title, :description, :assigned_to_id, :status)
  end

  def set_case
    @case = Case.find(params[:id])
  end

  def set_dispute_anaysts
    @users = User.all.where(role_type: 'dispute_analyst')
  end

end
