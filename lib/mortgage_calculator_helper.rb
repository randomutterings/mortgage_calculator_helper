# MortgageCalculatorHelper
module MortgageCalculatorHelper

  # This function does the actual mortgage calculations
  # by plotting a PVIFA (Present Value Interest Factor of Annuity)
  def get_interest_factor(month_term, monthly_interest_rate)
      factor = 0
      base_rate = 1 + monthly_interest_rate
      denominator = base_rate
      month_term.times do
        factor += (1 / denominator)
        denominator *= base_rate
      end
      factor
  end
  
  def mortgage_calculator_tag(sale_price = "150000", annual_interest_percent = 7.0, year_term = 30, down_percent = 10, show_progress = true)
    output = ""
    unless params[:form_complete].nil?
      sale_price                = params[:sale_price].gsub(/[^0-9\.]/, "").to_f
      annual_interest_percent   = params[:annual_interest_percent].gsub(/[^0-9\.]/, "").to_f
      year_term                 = params[:year_term].gsub(/[^0-9\.]/, "").to_i
      down_percent              = params[:down_percent].gsub(/[^0-9\.]/, "").to_f
      form_complete             = params[:form_complete]
      if params[:show_progress].nil?
        show_progress = false
      else
        show_progress = true
      end
        
      if year_term <= 0 || sale_price <= 0 || annual_interest_percent <= 0
        error = "You must enter a Sale Priceof Home, Length of Mortgage <i>and</i> Annual Interest Rate"
      end
      
      if error.nil?
        month_term              = year_term * 12
        down_payment            = sale_price * (down_percent / 100)
        annual_interest_rate    = annual_interest_percent / 100
        monthly_interest_rate   = annual_interest_rate / 12
        financing_price         = sale_price - down_payment
        monthly_factor          = get_interest_factor(month_term, monthly_interest_rate)
        monthly_payment         = financing_price / monthly_factor
      end
    end

    unless error.nil?
        output << content_tag(:div, error, :class => "mortgage_calculator_error")
        form_complete = nil
    end
    
    output << content_tag(:div, "Mortgage Calculator", :class => "mortgage_calculator_title")
    output << content_tag(:div, "This mortgage calculator can be used to figure out monthly payments of a home mortgage loan, based on the home's sale price, the term of the loan desired, buyer's down payment percentage, and the loan's interest rate. This calculator factors in PMI (Private Mortgage Insurance) for loans where less than 20% is put as a down payment. Also taken into consideration are the town property taxes, and their effect on the total monthly mortgage payment.", :class => "mortgage_calculator_information")
    
    output << tag(:div, :class => "mortgage_calculator_form")
    output << "<form action='#{request.request_uri}' method='put'>"
    output << hidden_field_tag("form_complete", "1")
    output << content_tag(:div, "Purchase &amp; Financing Information", :class => "mortgage_calculator_header")
    output << tag(:br)
    output << tag("table", { :cellpadding => "5", :cellspacing => "0", :border => "0", :width => "100%" }, false, false)
    
    output << tag(:tr, false, false)
    output << content_tag(:td, label_tag('sale_price', 'Sale Price of Home:'), :style => "text-align:right;")
    output << content_tag(:td, "#{text_field_tag('sale_price', sale_price)}(In Dollars)")
    output << tag("/tr", false, false)
    
    output << tag(:tr, false, false)
    output << content_tag(:td, label_tag('down_percent', 'Percentage Down:'), :style => "text-align:right;")
    output << content_tag(:td, "#{text_field_tag('down_percent', down_percent)}%")
    output << tag("/tr", false, false)
    
    output << tag(:tr, false, false)
    output << content_tag(:td, label_tag('year_term', 'Length of Mortgage:'), :style => "text-align:right;")
    output << content_tag(:td, "#{text_field_tag('year_term', year_term)}years")
    output << tag("/tr", false, false)
    
    output << tag(:tr, false, false)
    output << content_tag(:td, label_tag('annual_interest_percent', 'Annual Interest Rate:'), :style => "text-align:right;")
    output << content_tag(:td, "#{text_field_tag('annual_interest_percent', annual_interest_percent)}%")
    output << tag("/tr", false, false)
    
    output << tag(:tr, false, false)
    output << content_tag(:td, label_tag('show_progress', 'Explain Calculations:'), :style => "text-align:right;")
    output << content_tag(:td, "#{check_box_tag('show_progress', '1', show_progress)}Show me the calculations and amortization")
    output << tag("/tr", false, false)
    
    output << tag(:tr, false, false)
    output << content_tag(:td, "&nbsp;")
    output << content_tag(:td, submit_tag("Calculate"))
    output << tag("/tr", false, false)
    
    unless form_complete.nil?
      output << tag(:tr, false, false)
      output << content_tag(:td, "&nbsp;")
      output << content_tag(:td, link_to_unless(form_complete.nil?, "Start Over", request.url.gsub!(/\?.$/, "")))
      output << tag("/tr", false, false)
    end
    
    output << tag("/table", false, false)
    output << tag("/form")
    output << tag("/div")
      
    # If the form has already been calculated, the down_payment
    # and monthly_payment variables will be displayed
    unless form_complete.nil? || monthly_payment.nil?
      output << content_tag(:div, "Mortgage Payment Information", :class => "mortgage_calculator_header")
      
      output << tag("table", { :cellpadding => "5", :cellspacing => "0", :border => "0", :width => "100%" }, false, false)
      
      output << tag(:tr, false, false)
      output << content_tag(:td, "Down Payment:", :style => "text-align:right;width:200px;", :class => "mortgage_calculator_payment_info")
      output << content_tag(:td, number_to_currency(down_payment), :class => "mortgage_calculator_payment_info mortgage_calculator_emphasis")
      output << tag("/tr", false, false)
      
      output << tag(:tr, false, false)
      output << content_tag(:td, "Amount Financed:", :style => "text-align:right;", :class => "mortgage_calculator_payment_info")
      output << content_tag(:td, number_to_currency(financing_price), :class => "mortgage_calculator_payment_info mortgage_calculator_emphasis")
      output << tag("/tr", false, false)
      
      output << tag(:tr, false, false)
      output << content_tag(:td, "Monthly Payment:", :style => "text-align:right;", :class => "mortgage_calculator_payment_total")
      output << content_tag(:td, "#{content_tag(:span, number_to_currency(monthly_payment), :class => 'mortgage_calculator_emphasis')}<br>(Principal &amp; Interest ONLY)", :class => "mortgage_calculator_payment_total")
      output << tag("/tr", false, false)
      
      if down_percent < 20
        pmi_per_month = 55 * (financing_price / 100000)
        output << tag(:tr, false, false)
        output << content_tag(:td, "&nbsp;", :class => "mortgage_calculator_pmi_info")
        output << content_tag(:td, "Since you are putting LESS than 20% down, you will need to pay PMI (<a href='http:#www.google.com/search?hl=en&q=private+mortgage+insurance'>Private Mortgage Insurance</a>), which tends to be about $55 per month for every $100,000 financed (until you have paid off 20% of your loan). This could add #{number_to_currency(pmi_per_month)} to your monthly payment.", :class => "mortgage_calculator_pmi_info")
        output << tag("/tr", false, false)
        
        output << tag(:tr, false, false)
        output << content_tag(:td, "Monthly Payment:", :style => "text-align:right;", :class => "mortgage_calculator_pmi_total")
        output << content_tag(:td, "#{content_tag(:span, number_to_currency(monthly_payment + pmi_per_month), :class => 'mortgage_calculator_emphasis')}<br>(Principal &amp; Interest and PMI)", :class => "mortgage_calculator_pmi_total")
        output << tag("/tr", false, false)
      end
        
      assessed_price          = (sale_price * 0.85);
      residential_yearly_tax  = (assessed_price / 1000) * 14;
      residential_monthly_tax = residential_yearly_tax / 12;
      pmi_text = "PMI and " unless pmi_per_month.nil?

      output << tag(:tr, false, false)
      output << content_tag(:td, "&nbsp;", :class => "mortgage_calculator_prop_tax_info")
      output << content_tag(:td, "Residential (or Property) Taxes are a little harder to figure out... In Massachusetts, the average resedential tax rate seems to be around $14 per year for every $1,000 of your property's assessed value.<br><br>Let's say that your property's <i>assessed value</i> is 85% of what you actually paid for it - #{number_to_currency(assessed_price)}. This would mean that your yearly residential taxes will be around #{number_to_currency(residential_yearly_tax)}.  This could add #{number_to_currency(residential_monthly_tax)} to your monthly payment.", :class => "mortgage_calculator_prop_tax_info")
      output << tag("/tr", false, false)
      
      output << tag(:tr, false, false)
      output << content_tag(:td, "TOTAL Monthly Payment:", :style => "text-align:right;", :class => "mortgage_calculator_prop_tax_total")
      output << content_tag(:td, "#{content_tag(:span, number_to_currency(monthly_payment + pmi_per_month + residential_monthly_tax), :class => 'mortgage_calculator_emphasis')}<br>(including #{pmi_text}residential tax)", :class => "mortgage_calculator_prop_tax_total")
      output << tag("/tr", false, false)
      
      output << tag("/table", false, false)
    end
  
    output << tag(:br)
  
    # This prints the calculation progress and 
    # the instructions of how everything is figured out
    unless form_complete.nil? || show_progress.nil?
      step = 1;
      output << tag("table", { :cellpadding => "5", :cellspacing => "0", :border => "1", :width => "100%" }, false, false)
      
      output << tag(:tr, false, false)
      output << content_tag(:td, step, :class => "mortgage_calculator_emphasis")
      output << content_tag(:td, "The <span class='mortgage_calculator_emphasis'>down payment</span> = The price of the home multiplied by the percentage down divided by 100 (for 5% down becomes 5/100 or 0.05)<br><br>#{number_to_currency(down_payment)} = #{number_to_currency(sale_price)} X (#{down_percent.to_i} / 100)")
      output << tag("/tr", false, false)
      
      output << tag(:tr, false, false)
      output << content_tag(:td, step = step + 1, :class => "mortgage_calculator_emphasis")
      output << content_tag(:td, "The <span class='mortgage_calculator_emphasis'>interest rate</span> = The annual interest percentage divided by 100<br><br>#{annual_interest_rate} = #{annual_interest_percent.to_i}% / 100")
      output << tag("/tr", false, false)
      
      output << tag(:tr, false, false)
      output << content_tag(:td, "The <span class='mortgage_calculator_emphasis'>monthly factor</span> = The result of the following formula:", :colspan => "2", :class => "mortgage_calculator_dark_shade")
      output << tag("/tr", false, false)
      
      output << tag(:tr, false, false)
      output << content_tag(:td, step = step + 1, :class => "mortgage_calculator_emphasis")
      output << content_tag(:td, "The <span class='mortgage_calculator_emphasis'>monthly interest rate</span> = The annual interest rate divided by 12 (for the 12 months in a year)<br><br>#{monthly_interest_rate} = #{annual_interest_rate} / 12")       
      output << tag("/tr", false, false)
      
      output << tag(:tr, false, false)
      output << content_tag(:td, step = step + 1, :class => "mortgage_calculator_emphasis")
      output << content_tag(:td, "The <span class='mortgage_calculator_emphasis'>month term</span> of the loan in months = The number of years you've taken the loan out for times 12<br><br>#{month_term} Months = #{year_term} Years X 12")
      output << tag("/tr", false, false)
      
      output << tag(:tr, false, false)
      output << content_tag(:td, step = step + 1, :class => "mortgage_calculator_emphasis")
      output << content_tag(:td, "The <span class='mortgage_calculator_emphasis'>montly payment</span> is figured out using the following formula:<br>Monthly Payment = #{number_to_currency(financing_price)} * (#{number_with_precision(monthly_interest_rate, :precision => 4)} / (1 - ((1 + #{number_with_precision(monthly_interest_rate, :precision => 4)}) <sup>-(#{month_term})</sup>)))<br><br>The <a href='#amortization'>amortization</a> breaks down how much of your monthly payment goes towards the bank's interest, and how much goes into paying off the principal of your loan.")
      output << tag("/tr", false, false)
      
      output << tag("/table", false, false)
      
      principal     = financing_price
      current_month = 1
      current_year  = 1
      
      # This basically, re-figures out the monthly payment, again.
      power = -(month_term.to_i)
      denom = (1 + monthly_interest_rate) ** power
      monthly_payment = principal * (monthly_interest_rate / (1 - denom))

      output << content_tag(:div, "<br><br><a name='amortization'></a>Amortization For Monthly Payment: #{number_to_currency(monthly_payment)} over #{year_term} years.")
      output << tag("table", { :cellpadding => "5", :cellspacing => "0", :border => "1", :width => "100%" }, false, false)
      
      # This LEGEND will get reprinted every 12 months
      legend = "<td align='right' class='mortgage_calculator_dark_shade mortgage_calculator_emphasis'>Month</td>
                <td align='right' class='mortgage_calculator_dark_shade mortgage_calculator_emphasis'>Interest Paid</td>
                <td align='right' class='mortgage_calculator_dark_shade mortgage_calculator_emphasis'>Principal Paid</td>
                <td align='right' class='mortgage_calculator_dark_shade mortgage_calculator_emphasis'>Remaing Balance</td>"
      
      output << content_tag(:tr, legend)

      # Loop through and get the current month's payments for the length of the loan 
      this_year_interest_paid = 0
      this_year_principal_paid = 0
      
      while current_month.to_i <= month_term.to_i
        interest_paid     = principal * monthly_interest_rate
        principal_paid    = monthly_payment - interest_paid
        remaining_balance = principal - principal_paid

        this_year_interest_paid  = this_year_interest_paid + interest_paid
        this_year_principal_paid = this_year_principal_paid + principal_paid

        output << tag("tr", false, false)
        output << content_tag(:td, current_month, :class => "mortgage_calculator_light_shade")
        output << content_tag(:td, number_to_currency(interest_paid), :class => "mortgage_calculator_light_shade")
        output << content_tag(:td, number_to_currency(principal_paid), :class => "mortgage_calculator_light_shade")
        output << content_tag(:td, number_to_currency(remaining_balance), :class => "mortgage_calculator_light_shade")
        output << tag("/tr", false, false)
        
        (current_month % 12 == 0) ? show_legend = true : show_legend = false

        if show_legend == true
          output << content_tag(:tr, content_tag(:td, "Totals for year #{current_year}", :colspan => "4"), :class => "mortgage_calculator_year_totals mortgage_calculator_emphasis")
          
          total_spent_this_year = this_year_interest_paid + this_year_principal_paid
          output << tag("tr", false, false)
          output << content_tag(:td, "&nbsp;", :class => "mortgage_calculator_year_totals")
          output << content_tag(:td, "You will spend #{number_to_currency(total_spent_this_year)} on your house in year #{current_year}<br>#{number_to_currency(this_year_interest_paid)} will go towards INTEREST<br>#{number_to_currency(this_year_principal_paid)} will go towards PRINCIPAL<br>", :colspan => "3", :class => "mortgage_calculator_year_totals")
          output << tag("/tr", false, false)
          
          output << content_tag(:tr, content_tag(:td, "&nbsp;", :colspan => "4"))
          
          current_year = current_year + 1
          this_year_interest_paid  = 0
          this_year_principal_paid = 0

          if (current_month + 6) < month_term
            output << content_tag(:tr, legend)
          end
        end
        
        principal = remaining_balance
        current_month = current_month + 1
      end
      
      output << tag("/table", false, false)
    end
    output
  end
  
end