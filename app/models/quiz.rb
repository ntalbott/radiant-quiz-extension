class Quiz
  attr_reader :errors
  
  class Errors < Hash
    alias :on :[]
  end

  def initialize(config, questions)
    @required = config[:questions]
    @results = config[:results].collect{|k,v| [k.to_i,v]}.sort_by{|e| e.first}
    @questions = questions
    @errors = Errors.new
  end
  
  def valid?
    @errors = Errors.new
    @required.each_with_index do |r,i|
      name = "question_#{i+1}"
      unless @questions && @questions[name]
        @errors[name] = true
      end
    end
    @errors.empty?
  end
  
  def result
    total = @questions.collect{|k,v| v.to_i}.sum
    (@results.detect{|k,v| k >= total} || @results.last).last
  end
end