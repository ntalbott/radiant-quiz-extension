class QuizExtension < Radiant::Extension
  version "1.0"
  description "Allows the creation of simple web quizzes."
  url "http://terralien.com/"
  
  define_routes do |map|
    map.resource :quiz, :path_prefix => "/pages/:page_id", :controller => "quiz"
  end
  
  def activate
    Page.send :include, QuizTags
  end
  
  def deactivate
  end
  
end