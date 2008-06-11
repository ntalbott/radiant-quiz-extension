require File.dirname(__FILE__) + '/../test_helper'

class QuizTest < ActionController::IntegrationTest
  def setup
    @page = Page.create!(:title => 'Quiz!', :slug => '/', :breadcrumb => 'home', :status => Status[:published])
    PagePart.create!(:name => 'quiz', :page => @page, :content => quiz_config)
    PagePart.create!(:name => 'body', :page => @page, :content => quiz_body)

    @url = %(/pages/#{@page.id}/quiz)
  end
  
  def test_quiz_basics
    get '/'
    assert_select %(form[action=#{@url}][method=post]) do
      assert_select %(input[name='questions[question_1]'][value=1])
      assert_select %(input[name='questions[question_1]'][value=2])
      assert_select %(input[name='questions[question_1]'][value=3])
    end
    
    post @url, :questions => {:question_1 => '1', :question_2 => '1', :question_3 => '1'}
    assert_redirected_to '/result1'

    post @url, :questions => {:question_1 => '1', :question_2 => '1', :question_3 => '2'}
    assert_redirected_to '/result2'

    post @url, :questions => {:question_1 => '1', :question_2 => '2', :question_3 => '2'}
    assert_redirected_to '/result2'

    post @url, :questions => {:question_1 => '1', :question_2 => '2', :question_3 => '3'}
    assert_redirected_to '/result3'

    post @url, :questions => {:question_1 => '3', :question_2 => '3', :question_3 => '3'}
    assert_redirected_to '/result3'
  end
  
  def test_error_handling
    post @url
    assert_response :success
    assert_select '#error'
    assert_select '#error_on_question_1'
    assert_select '#error_on_question_2'
    assert_select '#error_on_question_3'
    
    post @url, :questions => {:question_1 => '1'}
    assert_response :success
    assert_select '#error'
    assert_select '#error_on_question_1', false
    assert_select '#error_on_question_2'
    assert_select '#error_on_question_3'
    
    post @url, :questions => {:question_1 => '1', :question_2 => '1', :question_3 => '1'}
    assert_response :redirect
    assert_select '#error', false
    assert_select '#error_on_question_1', false
    assert_select '#error_on_question_2', false
    assert_select '#error_on_question_3', false
  end
  
  def quiz_body
    return <<-BODY.chomp
<r:quiz:form>
  <r:error><p id="error"></p></r:error>
  <r:questions:each>
    <h2><r:question /></h2>
    <r:error><p id="error_on_<r:question_name />"></p></r:error>
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