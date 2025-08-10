class PagesController < ApplicationController
  skip_before_action :authenticate, only: [:home, :pricing, :help, :about, :press]
  def home
    # if user_signed_in?
    #   redirect_to dashboard_path
    # end
  end

  def pricing
  end

  def help
  end

  def about
  end

  def press
  end
end
