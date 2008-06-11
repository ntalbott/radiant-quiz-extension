class QuizExtension < Radiant::Extension
  version "1.0"
  description "Allows the creation of simple web quizzes."
  url "http://terralien.com/"
  
  define_routes do |map|
    map.resource :quiz, :path_prefix => "/pages/:page_id", :controller => "quiz"
  end
  
  def activate
    Page.class_eval do
      include QuizTags
      attr_accessor :last_quiz
    end
  end
  
  def deactivate
  end
  
end