require File.dirname(__FILE__) + '/../test_helper'

class QuizTest < ActionController::IntegrationTest
  def test_quiz_basics
    page = Page.create!(:title => 'Quiz!', :slug => '/', :breadcrumb => 'home', :status => Status[:published])

    quiz_part = PagePart.create!(:name => 'quiz', :page => page, :content => quiz_config)
    body_part = PagePart.create!(:name => 'body', :page => page, :content => quiz_body)
    
    get '/'
    assert_select 'form[action=/quizzing][method=post]' do
      assert_select %(input[name='questions[question_0]'][value=1])
      assert_select %(input[name='questions[question_0]'][value=2])
      assert_select %(input[name='questions[question_0]'][value=3])
      assert_select %(input[name='required[question_0]'][value=1])
      assert_select %(input[name='results[3]'][value=/result1])
      assert_select %(input[name='results[5]'][value=/result2])
      assert_select %(input[name='results[8]'][value=/result3])
    end
    
    post '/quizzing', 
      :required => {:question_0 => '1', :question_1 => '1', :question_2 => '1'},
      :questions => {:question_0 => '1', :question_1 => '1', :question_2 => '1'},
      :results => {'3' => '/result1', '5' => '/result2', '8' => '/result3'}
    assert_redirected_to '/result1'

    post '/quizzing', 
      :required => {:question_0 => '1', :question_1 => '1', :question_2 => '1'},
      :questions => {:question_0 => '1', :question_1 => '1', :question_2 => '2'},
      :results => {'3' => '/result1', '5' => '/result2', '8' => '/result3'}
    assert_redirected_to '/result2'

    post '/quizzing', 
      :required => {:question_0 => '1', :question_1 => '1', :question_2 => '1'},
      :questions => {:question_0 => '1', :question_1 => '2', :question_2 => '2'},
      :results => {'3' => '/result1', '5' => '/result2', '8' => '/result3'}
    assert_redirected_to '/result2'

    post '/quizzing', 
      :required => {:question_0 => '1', :question_1 => '1', :question_2 => '1'},
      :questions => {:question_0 => '1', :question_1 => '2', :question_2 => '3'},
      :results => {'3' => '/result1', '5' => '/result2', '8' => '/result3'}
    assert_redirected_to '/result3'

    post '/quizzing', 
      :required => {:question_0 => '1', :question_1 => '1', :question_2 => '1'},
      :questions => {:question_0 => '3', :question_1 => '3', :question_2 => '3'},
      :results => {'3' => '/result1', '5' => '/result2', '8' => '/result3'}
    assert_redirected_to '/result3'
  end
  
  def quiz_body
    return <<-BODY.chomp
<r:quiz:form>
  <r:questions:each>
    <h2><r:question /></h2>
    <ol>
      <r:options:each>
        <li><r:option_radio /> <r:option_label /></li>
      </r:options:each>
    </ol>
  </r:questions:each>
</r:quiz:form>
BODY
  end
  
  def quiz_config
    return <<-CONFIG.chomp
questions:
  -
    - "Q1"
    - 1: "Q1O1"
    - 2: "Q1O2"
    - 3: "Q1O3"
  -
    - "Q2"
    - 3: "Q2O1"
    - 2: "Q2O2"
    - 1: "Q2O3"
  -
    - "Q3"
    - 1: "Q3O1"
    - 3: "Q3O2"
    - 2: "Q3O3"
results:
  3: "result1"
  5: "result2"
  8: "result3"
CONFIG
  end
end