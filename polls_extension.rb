class PollsExtension < Radiant::Extension
  version "1.0"
  description "Allows the creation of simple web polls."
  url "http://terralien.com/"
  
  define_routes do |map|
    map.connect 'polls', :controller => 'polls', :action => 'submit'
  end
  
  def activate
    Page.send :include, PollTags
  end
  
  def deactivate
  end
  
end