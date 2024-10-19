require 'rails_helper'

RSpec.describe Case, type: :model do
  let!(:curr_case) { create(:case) }

  context 'case is valid' do
    it 'with the valid attributes' do
      expect(curr_case).to be_valid
    end

    it 'has default status of open' do
      expect(curr_case.status).to eq('open')
    end

    it 'generates a case_number with the alphanumeric format of size 6' do
      expect(curr_case.case_number).to match(/^#[0-9A-F]{6}$/)
    end
  end

  context 'case is not valid' do
    it 'is invalid with empty title or description' do
      curr_case.title = nil
      curr_case.description = nil
      expect(curr_case).not_to be_valid
      errors = curr_case.errors
      expect(errors[:title]).to include("can't be blank")
      expect(errors[:description]).to include("can't be blank")
    end

    it 'is invalid if duplicate case_numbers' do
      duplicate_case = create(:case)
      duplicate_case.update(case_number: curr_case.case_number)
      expect(duplicate_case.errors[:case_number]).to include('has already been taken')
    end
  end
end
