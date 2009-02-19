require 'test/unit'
require File.dirname(__FILE__) + '/../../../../config/boot.rb'
require File.dirname(__FILE__) + '/../../../../config/environment.rb'

class MortgageCalculatorTest < Test::Unit::TestCase
  
  include MortgageCalculatorHelper
  
  def setup
    @helper = ActionView::Base.new
    params[:form_complete] = "1"
    params[:sale_price] = "150000"
    params[:annual_interest_percent] = "7.0"
    params[:year_term] = "30"
    params[:down_percent] = "10"
    params[:show_progress] = "1"
  end

  def test_mortgage_calculator
    output = mortgage_calculator_tag
    assert_equal '<img src="/images/logo.png" />', output
  end
  
end
