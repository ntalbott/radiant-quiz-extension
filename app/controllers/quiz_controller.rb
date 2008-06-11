class QuizController < ApplicationController
  session :off
  no_login_required
  skip_before_filter :verify_authenticity_token
  
  def create
    page = Page.find(params[:page_id])
    config = config(page)
    required = config[:questions]
    results = config[:results].collect{|k,v| [k.to_i,"#{page.url}#{v}"]}.sort_by{|e| e.first}
    if params[:questions] and required.size == params[:questions].size
      total = params[:questions].collect{|k,v| v.to_i}.sum
      result = (results.detect{|k,v| k >= total} || results.last)
      redirect_to result.last
    else
      if page.published?
        page.request, page.response = request, response
        render :text => page.render
      else
        render :text => %(Quiz not found.)
      end
    end
  end
  
  private
  
  def config(page)
    string = page.render_part(:quiz)
    (string.empty? ? {} : YAML::load(string).symbolize_keys)
  end
end
