class PassthroughController < ApplicationController
  def index
    if user_signed_in?
      redirect_to user_path(current_user), :notice => "This is where its messing up"
    else
      redirect_to home_path
    end
  end
end
