module QuizTags
  include Radiant::Taggable

  tag "quiz" do |tag|
    source = tag.attr["source"]
    if source
      source_page = Page.find_by_url(source, tag.locals.page.published?)
      return "source page not found." unless source_page
      tag.locals.page = source_page
    end

    config = tag.locals.page.part('quiz')
    if config
      tag.locals.quiz_config = YAML.load(config.content)
    else
      return "Quizzes require a quiz page part."
    end
    tag.expand
  end
    
  tag "quiz:teaser" do |tag|
    question = tag.locals.quiz_config['questions'].first
    tag.locals.question_name = "question_1"
    tag.locals.question_text = question[0]
    tag.locals.question_options = question[1..-1]

    result = []
    result << %(<form action="#{tag.locals.page.url}" method="post" id="quiz_teaser">)
    result <<   tag.expand
    result << %(</form>)
    result
  end
  
  tag "quiz_teaser:question" do |tag|
  end
  
  tag "quiz:form" do |tag|
    validation_message = tag.attr["validation_message"] || "Please provide an answer for all the questions."
    result = []
    result << %(<form action="/pages/#{tag.locals.page.id}/quiz" method="post" id="quiz">)
    result <<   tag.expand
    result << %(</form>)
    result
  end
  
  tag "quiz:questions" do |tag|
    tag.expand
  end
  
  tag "quiz:questions:each" do |tag|
    result = []
    tag.locals.quiz_config['questions'].each_with_index do |q,i|
      tag.locals.question_name = "question_#{i+1}"
      tag.locals.question_text = q[0]
      tag.locals.question_options = q[1..-1]
      result << tag.expand
    end
    result
  end
  
  tag "quiz:error" do |tag|
    quiz = tag.locals.page.last_quiz
    if quiz
      if name = tag.locals.question_name 
        if quiz.errors.on(name)
          tag.expand
        end
      elsif !quiz.valid?
        result = tag.expand
      end
    end
  end
  
  tag "quiz:question" do |tag|
    tag.locals.question_text
  end
  
  tag "quiz:question_name" do |tag|
    tag.locals.question_name
  end
  
  tag "quiz:options" do |tag|
    tag.expand
  end
  
  tag "quiz:options:each" do |tag|
    if tag.locals.question_options
      result = []
      tag.locals.question_options.each_with_index do |o,i|
        tag.locals.question_option_name = "#{tag.locals.question_name}_option_#{i}"
        tag.locals.question_option_weight = o.keys.first
        tag.locals.question_option_text = o.values.first
        result << tag.expand
      end
      result
    end
  end
  
  tag "quiz:options:each:option_radio" do |tag|
    checked = false
    if questions = tag.locals.page.request.parameters["questions"]
      checked = (questions[tag.locals.question_name].to_i == tag.locals.question_option_weight)
    end
    %(<input type="radio" name="questions[#{tag.locals.question_name}]" id="#{tag.locals.question_option_name}" value="#{tag.locals.question_option_weight}" #{%(checked="checked") if checked}/>)
  end
  
  tag "quiz:options:each:option_label" do |tag|
    %(<label for="#{tag.locals.question_option_name}">#{tag.locals.question_option_text}</label>)
  end
end