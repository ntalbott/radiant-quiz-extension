module PollTags
  include Radiant::Taggable

  tag "poll" do |tag|
    source = tag.attr["source"]
    if source
      source_page = Page.find_by_url(source, tag.locals.page.published?)
      return "source page not found." unless source_page
      tag.locals.page = source_page
    end

    config = tag.locals.page.part('poll')
    if config
      tag.locals.poll_config = YAML.load(config.content)
    else
      return "Polls require a poll page part."
    end
    tag.expand
  end
    
  tag "poll:teaser" do |tag|
    question = tag.locals.poll_config['questions'].first
    tag.locals.question_name = "question_0"
    tag.locals.question_text = question[0]
    tag.locals.question_options = question[1..-1]

    result = []
    result << %(<form action="#{tag.locals.page.url}" method="post" id="poll_teaser">)
    result <<   tag.expand
    result << %(</form>)
    result
  end
  
  tag "poll_teaser:question" do |tag|
  end
  
  tag "poll:form" do |tag|
    validation_message = tag.attr["validation_message"] || "Please provide an answer for all the questions."
    result = []
    result << %(<form action="/polls" method="post" id="poll">)
    result <<   %(<div style="display:none">)
    tag.locals.poll_config['results'].each do |(k,v)|
      result <<   %(<input type="hidden" name="results[#{k}]" value="#{tag.locals.page.url}#{v}" />)
    end
    result <<     %(<input type="hidden" name="validation_message" value="#{validation_message}" />)
    result <<     %(<input type="hidden" name="location" value="#{tag.locals.page.url}" />)
    result <<   %(</div>)
    result <<   tag.expand
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
    result = []
    tag.locals.poll_config['questions'].each_with_index do |q,i|
      tag.locals.question_name = "question_#{i}"
      tag.locals.question_text = q[0]
      tag.locals.question_options = q[1..-1]
      result << tag.expand
    end
    result
  end
  
  tag "poll:question" do |tag|
    tag.locals.question_text
  end
  
  tag "poll:options" do |tag|
    tag.expand
  end
  
  tag "poll:options:each" do |tag|
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
  
  tag "poll:options:each:option_radio" do |tag|
    checked = false
    if questions = tag.locals.page.request.parameters["questions"]
      checked = (questions[tag.locals.question_name].to_i == tag.locals.question_option_weight)
    end
    %(<input type="radio" name="questions[#{tag.locals.question_name}]" id="#{tag.locals.question_option_name}" value="#{tag.locals.question_option_weight}" #{%(checked="checked") if checked}/>)
  end
  
  tag "poll:options:each:option_label" do |tag|
    %(<label for="#{tag.locals.question_option_name}">#{tag.locals.question_option_text}</label>)
  end
end