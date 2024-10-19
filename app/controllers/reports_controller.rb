require 'csv'

class ReportsController < ApplicationController
  before_action :authenticate_case_manager!

  def set_case_manager
    user = User.find(params[:id])
    if user.update(role_type: 'case_manager')
      flash[:notice] = 'Success!'
    else
      flash[:alert] = 'Error!'
    end
    redirect_to dispute_analysts_details_reports_path
  end

  def cases_details
    @cases = Case.includes(:user, :assigned_to).order(:created_at)
    respond_to do |format|
      headers = ['ID', 'Case Number', 'Reported By', 'Assigned To', 'Title', 'Status', 'Created At', 'Updated At']
      attributes = [
        :id,
        :case_number,
        ->(item) { item.user.full_name },
        ->(item) { item.assigned_to.present? ? item.assigned_to.full_name : 'Unassigned' },
        :title,
        ->(item) { item.status.capitalize },
        ->(item) { item.created_at.strftime("%d %b %y") },
        ->(item) { item.updated_at.strftime("%d %b %y") }
      ]
      format.csv do
        response.headers['Content-Type'] = 'text/csv'
        response.headers['Content-Disposition'] = "attachment; filename=cases_details.csv"
        render plain: generate_csv(@cases, headers, attributes)
      end
      format.pdf do
        pdf = generate_pdf(@cases, headers, attributes, "Cases Records")
        send_data pdf.render, filename: 'cases_details.pdf', type: 'application/pdf'
      end
      format.html do
        @cases = @cases.paginate(page: params[:page], per_page: 20)
      end
    end
  end

  def case_status_distribution
    @cases = Case.group(:status).count
    respond_to do |format|
      headers = ['Case Status', 'Total Cases']
      attributes = [
        ->(item) { item[0].capitalize },
        ->(item) { item[1] }
      ]
      format.csv do
        response.headers['Content-Type'] = 'text/csv'
        response.headers['Content-Disposition'] = "attachment; filename=case_status_distribution.csv"
        render plain: generate_csv(@cases, headers, attributes)
      end
      format.pdf do
        pdf = generate_pdf(@cases, headers, attributes, "Case Status Distribution")
        send_data pdf.render, filename: 'case_status_distribution.pdf', type: 'application/pdf'
      end
      format.html do
      end
    end
  end

  def case_managers_details
    @users = User.includes(:cases)
                 .where(role_type: :case_manager)
                 .select('users.*, COUNT(cases.id) AS cases_reported_count')
                 .left_joins(:cases)
                 .group('users.id')
                 .order(:first_name, :last_name)
    respond_to do |format|
      headers = ['ID', 'Name', 'Age', 'Date of Birth', 'Email', 'Cases Reported']
      attributes = [
        :id,
        ->(item) { item.full_name },
        ->(item) { item.age},
        ->(item) { item.date_of_birth },
        ->(item) { item.email },
        ->(item) { item.cases_reported_count }
      ]
      format.csv do
        response.headers['Content-Type'] = 'text/csv'
        response.headers['Content-Disposition'] = "attachment; filename=case_manager_details.csv"
        render plain: generate_csv(@users, headers, attributes)
      end
      format.pdf do
        pdf = generate_pdf(@users, headers, attributes, "Case Manager Details")
        send_data pdf.render, filename: 'case_manager_details.pdf', type: 'application/pdf'
      end
      format.html do
        @users = @users.paginate(page: params[:page], per_page: 20)
      end
    end
  end

  def dispute_analysts_details
    @users = User.includes(:assigned_cases)
                  .where(role_type: :dispute_analyst)
                  .select('users.*, COUNT(cases.id) AS cases_assigned_count')
                  .left_joins(:assigned_cases)
                  .group('users.id')
                  .order(:first_name, :last_name)
    respond_to do |format|
      headers = ['ID', 'Name', 'Age', 'Date of Birth', 'Email', 'Cases Assigned']
      attributes = [
        :id,
        ->(item) { item.full_name },
        ->(item) { item.age},
        ->(item) { item.date_of_birth },
        ->(item) { item.email },
        ->(item) { item.cases_assigned_count }
      ]
      format.csv do
        response.headers['Content-Type'] = 'text/csv'
        response.headers['Content-Disposition'] = "attachment; filename=dispute_analyst_details.csv"
        render plain: generate_csv(@users, headers, attributes)
      end
      format.pdf do
        pdf = generate_pdf(@users, headers, attributes, "Dispute Analyst Details")
        send_data pdf.render, filename: 'dispute_analyst_details.pdf', type: 'application/pdf'
      end
      format.html do
        @users = @users.paginate(page: params[:page], per_page: 20)
      end
    end
  end


  private

  def generate_csv(collection, headers, attributes)
    CSV.generate(headers: true) do |csv|
      csv << headers
      collection.each do |item|
        csv << attributes.map do |attr|
          if attr.is_a?(Proc)
            attr.call(item)
          else
            item.send(attr)
          end
        end
      end
    end
  end

  def generate_pdf(collection, headers, attributes, title)
    formatted_headers = headers.map { |header| "<font size='12'><b>#{header}</b></font>" }
    formatted_records = collection.map do |item|
      attributes.map do |attr|
        if attr.is_a?(Proc)
          attr.call(item)
        else
          item.send(attr)
        end
      end
    end
    pdf = Prawn::Document.new
    pdf.text "#{title}", align: :center, size: 24
    pdf.table([formatted_headers] + formatted_records, width: pdf.bounds.width, header: true,
              cell_style: {
                borders: %i[top bottom left right],
                padding: 5,
                size: 10,
                inline_format: true
              })
    pdf.move_down 10
    pdf.text "#{collection.size} records", align: :right, size: 12
    pdf
  end

end
