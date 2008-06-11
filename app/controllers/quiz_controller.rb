class QuizController < ApplicationController
  session :off
  no_login_required
  skip_before_filter :verify_authenticity_token
  
  def create
    page = Page.find(params[:page_id])
    config = config(page)
    quiz = Quiz.new(config, params[:questions])
    if quiz.valid?
      redirect_to "#{page.url}#{quiz.result}"
    elsif page.published?
      page.last_quiz = quiz
      page.request, page.response = request, response
      render :text => page.render
    else
      render :text => %(Quiz not found.)
    end
  end
  
  private
  
  def config(page)
    string = page.render_part(:quiz)
    (string.empty? ? {} : YAML::load(string).symbolize_keys)
  end
end
