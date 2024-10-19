class CaseManagers::NotesController < ApplicationController
  before_action :authenticate_case_manager!, :set_case
  before_action :set_note, only: %i[edit update destroy]

  # new_case_managers_case_note
  def new
  end

  # case_managers_case_note
  def create
  	@note = Note.new(note_params)
  	if @note.save
      # UserMailer.new_note(@case, @note, current_user).deliver_now
  	  redirect_to case_managers_case_path(@case), notice: 'Note Added successfully!'
  	else
  	  redirect_to case_managers_case_path(@case), alert: "Note cant't be blank"
  	end
  end

  # case_managers_case_notes
  def index
  end

  # edit_case_managers_case_note(@note)
  def edit
  end

  # case_managers_case_note(@note)
  def update
    original_content = @note.content
    changes = {}
    if @note.update(note_params)
      changes[:content] = { before: original_content, after: @note.content } if original_content != @note.content
      # UserMailer.update_note(@case, @note, current_user, changes).deliver_now unless changes.empty?
      redirect_to case_managers_case_path(@case), notice: 'Note updated successfully!'
    else
      render :edit, status: 422
    end
  end

  def destroy
    @note.destroy
    redirect_to case_managers_case_path(@case), notice: 'Note deleted successfully!'
  end

  private

  def set_case
  	@case = Case.find(params[:case_id])
    if @case.status == 'closed'
      redirect_to case_managers_case_path(@case), alert: "Case closed!"
    end
  end

  def set_note
  	@note = Note.find(params[:id])
    unless @note.user == current_user
      redirect_to case_managers_case_path(@case), alert: 'Unauthorized access!'
    end
  end

  def note_params
  	params.require(:note).permit(:content, :user_id, :case_id)
  end
end
