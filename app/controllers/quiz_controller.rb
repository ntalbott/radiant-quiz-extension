class QuizController < ApplicationController
  session :off
  no_login_required
  skip_before_filter :verify_authenticity_token
  
  def process_quiz
    if params[:questions] and params[:required] and params[:required].size == params[:questions].size
      total = params[:questions].collect{|k,v| v.to_i}.sum
      results = params[:results].collect{|k,v| [k.to_i,v]}.sort_by{|e| e.first}
      result = (results.detect{|k,v| k >= total} || results.last)
      redirect_to result.last
    elsif(!params[:location].blank?)
      page = Page.find_by_url(params[:location])
      if page && page.published?
        page.request, page.response = request, response
        render :text => page.render
      else
        render :text => %(Quiz not found.)
      end
    else
      render :template => 'site/not_found', :status => 404
    end
  end
end
