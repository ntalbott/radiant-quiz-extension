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
    validation_message = tag.attr["validation_message"] || "Please provide an answer for all the questions."
    result << %(<form action="/polls" method="post" id="poll">)
      result << %(<div style="display:none">)
        CONFIG[tag]['results'].each do |(k,v)|
          result << %(<input type="hidden" name="results[#{k}]" value="#{tag.locals.page.url}#{v}" />)
        end
        result << %(<input type="hidden" name="validation_message" value="#{validation_message}" />)
        result << %(<input type="hidden" name="location" value="#{tag.locals.page.url}" />)
      result << %(</div>)
      result << tag.expand
    result << %(</form>)
    result << %(
      <script type="text/javascript">
      $('poll').observe('submit', function(event) {
        var radio_names = $$('#poll input[type=radio]').pluck('name').uniq();
        var checked = radio_names.collect(function(e) {
          return $$('#poll input[type=radio][name="' + e + '"]').pluck('checked').any();
        });
        if(!checked.all()) {
          alert("#{validation_message}");
          event.stop();
        }
      });
      </script>)
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