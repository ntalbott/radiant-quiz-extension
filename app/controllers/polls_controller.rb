class PollsController < ApplicationController
  no_login_required
  
  def submit
    if params[:questions]
      total = params[:questions].collect{|k,v| v.to_i}.sum
      results = params[:results].collect{|k,v| [k.to_i,v]}.sort_by{|e| e.first}
      redirect_to results.detect{|k,v| k >= total}.last
    else
      render :text => %(#{params[:validation_message]} <a href="#{params[:location]}">Return</a>.)
    end
  end
end
