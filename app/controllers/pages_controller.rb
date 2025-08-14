class PagesController < ApplicationController
  skip_before_action :authenticate, only: [ :home, :pricing, :help, :about, :press, :docs ]
  def home
  end

  def pricing
  end

  def help
  end

  def about
  end

  def press
  end

  def docs
  end
end
