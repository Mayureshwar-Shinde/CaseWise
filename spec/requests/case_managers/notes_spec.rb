require 'rails_helper'

RSpec.describe "CaseManagers::Notes", type: :request do
  describe "GET /note" do
    it "returns http success" do
      get "/case_managers/notes/note"
      expect(response).to have_http_status(:success)
    end
  end

end
