class UserMailer < ApplicationMailer
  default from: 'system@casewise.com'

  def welcome_email user
  	mail(to: user.email, subject: 'Welcome to CaseWise!')
  end

  def login user
  	mail(to: user.email, subject: "You’ve Logged in to CaseWise")
  end

  def update_case(case_instance, changes, updater)
  	@case = case_instance
  	@changes = changes
    @updater = updater
    @role = @updater.role_type
    subject = "Case #{@case.case_number} Update"
    recipients = []
    recipients << @case.user.email if @updater != @case.user
    recipients << @case.assigned_to.email if @case.assigned_to && @updater != @case.assigned_to
    mail(to: recipients, subject:) unless recipients.empty?
  end

  def new_note(case_instance, note, updater)
    @case = case_instance
    @note = note
    @updater = updater
    @role = @updater.role_type
    recipients = []
    recipients << @case.user.email if @updater != @case.user
    recipients << @case.assigned_to.email if @case.assigned_to && @updater != @case.assigned_to
    mail(to: recipients, subject: "New note added on Case #{@case.case_number}")
  end

  def update_note(case_instance, note, updater, changes)
    @case = case_instance
    @note = note
    @updater = updater
    @changes = changes
    @role = @updater.role_type
    recipients = []
    recipients << @case.user.email if @updater != @case.user
    recipients << @case.assigned_to.email if @case.assigned_to && @updater != @case.assigned_to
    mail(to: recipients, subject: "Updated note on Case #{@case.case_number}")
  end

  def new_appointment(appointment, scheduler)
    @appointment = appointment
    @scheduler = scheduler
    to = appointment.case_manager.email
    to = appointment.dispute_analyst.email if scheduler == appointment.case_manager
    mail(to: , subject: "New Appointment Scheduled on case #{@appointment.case.case_number}")
  end

  def update_appointment(appointment, changes)
    @appointment = appointment
    @changes = changes
    mail(to: @appointment.dispute_analyst.email, subject: "Appointment Updated on case #{@appointment.case_id}")
  end

  def new_email communication
    @communication = communication
    mail(to: @communication.to.email, subject: @communication.subject)
  end
end
