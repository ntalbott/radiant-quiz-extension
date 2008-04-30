class PollsController < ApplicationController
  no_login_required
  
  def submit
    results = params[:results].collect{|k,v| [k.to_i,v]}.sort_by{|e| e.first}
    total = params[:questions].collect{|k,v| v.to_i}.sum
    redirect_to results.detect{|k,v| k >= total}.last
  end
end
