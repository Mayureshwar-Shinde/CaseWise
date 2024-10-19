class AuditsController < ApplicationController
  before_action :authenticate_case_manager!

  def index
    @q = Audited::Audit.where.not(user: nil).ransack(params[:q])
    @audits = @q.result(distinct: true)
    @audits = @audits.paginate(page: params[:page], per_page: 10).order(created_at: :desc)
  end

  def show
    @audit = Audited::Audit.find(params[:id])
  end
end
