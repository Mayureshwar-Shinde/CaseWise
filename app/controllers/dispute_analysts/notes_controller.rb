class DisputeAnalysts::NotesController < ApplicationController
  before_action :authenticate_dispute_analyst!, :set_case
  before_action :set_note, only: %i[edit update destroy]

  # new_dispute_analysts_case_note
  def new
  end

  # dispute_analysts_case_note
  def create
  	@note = Note.new(note_params)
  	if @note.save
      # UserMailer.new_note(@case, @note, current_user).deliver_now
  	  redirect_to dispute_analysts_case_path(@case), notice: 'Note Added successfully!'
  	else
  	  redirect_to dispute_analysts_case_path(@case), alert: "Note cant't be blank"
  	end
  end

  # dispute_analysts_case_notes
  def index
  end

  # dispute_analysts_case_note(@note)
  def edit
  end

  # dispute_analysts_case_note(@note)
  def update
    original_content = @note.content
    changes = {}
    if @note.update(note_params)
      changes[:content] = { before: original_content, after: @note.content } if original_content != @note.content
      # UserMailer.update_note(@case, @note, current_user, changes).deliver_now unless changes.empty?
      redirect_to dispute_analysts_case_path(@case), notice: 'Note updated successfully!'
    else
      render :edit, status: 422
    end
  end

  def destroy
    @note.destroy
    redirect_to dispute_analysts_case_path(@case), notice: 'Note deleted successfully!'
  end

  private

  def set_case
  	@case = Case.find(params[:case_id])
    redirect_to dispute_analysts_case_path(@case), alert: "Case closed!" if @case.status == 'closed'
  end

  def set_note
  	@note = Note.find(params[:id])
    unless @note.user == current_user
      redirect_to dispute_analysts_case_path(@case), alert: 'Unauthorized access!'
    end
  end

  def note_params
  	params.require(:note).permit(:content, :user_id, :case_id)
  end
end
