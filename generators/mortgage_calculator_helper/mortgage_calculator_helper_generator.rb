class MortgageCalculatorHelperGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      m.file "stylesheet.css",  "public/stylesheets/mortgage_calculator_helper.css"
    end
  end
end
