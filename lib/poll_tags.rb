module PollTags
  include Radiant::Taggable

  CONFIG = proc do |tag|
    config = tag.locals.page.part('poll')
    if config
      YAML.load(config.content)
    else
      {}
    end
  end
  
  tag "poll" do |tag|
    result = []
    result << %(<form action="/polls" method="post">)
    result << %(<div>)
    CONFIG[tag]['results'].each do |(k,v)|
      result << %(<input type="hidden" name="results[#{k}]" value="#{tag.locals.page.url}#{v}" />)
    end
    result << %(</div>)
    result << tag.expand
    result << %(</form>)
    result
  end
  
  tag "poll:questions" do |tag|
    tag.expand
  end
  
  tag "poll:questions:each" do |tag|
    questions = CONFIG[tag]['questions']
    if questions
      result = []
      questions.each_with_index do |q,i|
        tag.locals.question_name = "question_#{i}"
        tag.locals.question_text = q[0]
        tag.locals.question_options = q[1..-1]
        result << tag.expand
      end
      result
    else
      "Polls require a poll page part."
    end
  end
  
  tag "poll:questions:each:question" do |tag|
    tag.locals.question_text
  end
  
  tag "poll:questions:each:options" do |tag|
    tag.expand
  end
  
  tag "poll:questions:each:options:each" do |tag|
    result = []
    tag.locals.question_options.each_with_index do |o,i|
      tag.locals.question_option_name = "#{tag.locals.question_name}_option_#{i}"
      tag.locals.question_option_weight = o.keys.first
      tag.locals.question_option_text = o.values.first
      result << tag.expand
    end
    result
  end
  
  tag "poll:questions:each:options:each:option_radio" do |tag|
    %(<input type="radio" name="questions[#{tag.locals.question_name}]" id="#{tag.locals.question_option_name}" value="#{tag.locals.question_option_weight}" />)
  end
  
  tag "poll:questions:each:options:each:option_label" do |tag|
    %(<label for="#{tag.locals.question_option_name}">#{tag.locals.question_option_text}</label>)
  end
end