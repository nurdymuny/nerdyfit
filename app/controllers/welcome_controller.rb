class WelcomeController < ApplicationController

  def index
  end

  def google_fit
    @data = User.get_fit_data (current_user.token)
  end
end
