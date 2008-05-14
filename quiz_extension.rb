class QuizExtension < Radiant::Extension
  version "1.0"
  description "Allows the creation of simple web quizzes."
  url "http://terralien.com/"
  
  define_routes do |map|
    map.connect 'quizzing', :controller => 'quiz', :action => 'process_quiz'
  end
  
  def activate
    Page.send :include, QuizTags
  end
  
  def deactivate
  end
  
end