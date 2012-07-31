class Customer
  include Mongoid::Document
  include Mongoid::Timestamps
  #define all fields in the customer model
  field :first_name, :type => String
  field :last_name, :type => String
  field :email, :type => String
  field :phone_number, :type => Integer
  field :customer_unqiue_id, :type => String
  field :address, :type => String
  field :city, :type => String
  field :state, :type => String
  field :country, :type => String
  field :zip_code, :type => Integer
  field :facebook_id, :type => String
  field :twitter_id, :type => String
  field :foursquare_id, :type => String  
  field :organisation_id, :type => Integer
  
  #define validation tules
  validates :first_name, :last_name, :presence => true
  validates :zip_code, :length => { :minimum => 4, :maximum => 6, :too_short => "must have at least %{count} words", :too_long => "%{count} characters is the maximum allowed" }, :if => Proc.new {|c| not c.zip_code.blank?}
  validates :zip_code, :numericality => true, :if => Proc.new {|c| not c.zip_code.blank?}
  
  #define association rule
  has_many :products  
  
  #Find customer details when customer information function is called during purchase history display
  def self.find_customer_details(user, first_name, last_name, facebook_id, twitterid)
      organisation_id = user.organisation.id          
      customer = Customer.where({:facebook_id => "#{facebook_id}", :organisation_id => organisation_id}).first            
      if customer.blank?
        customer = Customer.where({:twitter_id => "#{twitterid}", :organisation_id => organisation_id}).first
      end
      if customer.blank?
        customer = Customer.where({:first_name => "#{first_name}", :last_name => "#{last_name}", :organisation_id => organisation_id}).first
      end        
      if customer.blank?
        customer = Customer.where({:first_name => "#{first_name}", :organisation_id => organisation_id}).first
      end
      if customer.blank?
        customer = Customer.where({:last_name => "#{last_name}", :organisation_id => organisation_id}).first
      end      
      if customer.blank?          
        customer = Customer.where({:first_name => /^#{Regexp.quote(first_name)}/, :last_name => /^#{Regexp.quote(last_name)}/, :organisation_id => organisation_id}).first unless first_name.blank? || last_name.blank?
      end
      if customer.blank?
        customer = Customer.where({:first_name => /^#{Regexp.quote(first_name)}/, :organisation_id => organisation_id}).first unless first_name.blank?
      end
      if customer.blank?
        customer = Customer.where({:last_name => /^#{Regexp.quote(last_name)}/, :organisation_id => organisation_id}).first unless last_name.blank?
      end
    return customer
  end
  #Method for saving customeer records as well as products record after successful validation checking
  #This method is called when every row  from CSV is parsing and reading row by row
  def self.customer_build_from_csv(row, organisationid)
    # find existing customer from first name and last name 
    puts "*****Started the function customer_build_from_csv****"
    puts "****checking of customer from CSV*****"
    customer = Customer.where(:first_name => "#{row[0]}", :last_name => "#{row[1]}").first       
    logger = Logger.new('log/logfile.log') # Creating log file
    if customer.blank?
      puts "****Customer not found in table*****"
      customer = Customer.new
      puts "******Initialized and fillup the data in customers*******"
      customer.attributes ={
        :first_name => row[0],        
        :last_name => row[1],
        :email => row[2],
        :phone_number => row[3],
        :customer_unqiue_id => row[4],
        :address => row[5],
        :country => row[6],
        :state => row[7],
        :city => row[8],
        :zip_code => row[9],
        :facebook_id => row[10],
        :twitter_id => row[11],
        :foursquare_id => row[12]
      }
      puts "******fillup the data in customers completed*******"
      puts "****Going for validation**********"
      if customer.valid?   
        puts "****Customer is valid**********"
        customer.first_name = customer.first_name.downcase
        customer.last_name = customer.last_name.downcase
        customer.organisation_id = organisationid
        customer.save
        puts "****Customer data is saved*******"
        puts "****calling of product_build_from_csv*******"
        product = Product.product_build_from_csv(row)
        puts "****End of calling of product_build_from_csv*******"
        product.customer_id = customer.id   
        puts "****Customer data is saved*******"
        puts "****Going for product validation**********"
        if product.valid?
          puts "****Product is valid**********"
          product.save 
          puts "****Product data is saved*******"
        else         
          puts "****Product is invalid, error message is going to log file*******"
          Customer.product_error_messages(product)                                              
        end        
      else
        puts "****validation fails, customer is not valid error message is going to log file**********"
        logger.info "First Name:- #{customer.errors[:first_name]}" if customer.errors[:first_name].any?
        logger.info "Last Name:- #{customer.errors[:last_name]}" if customer.errors[:last_name].any?
      end      
    else  
      puts "****Customer found in table*****"
      logger.info "First Name: #{row[0]}, Last Name: #{row[1]}, Email ID #{row[2]}, Phone Number #{row[3]}, Address: #{row[5]}, City: #{row[6]}, FacebookID: #{row[7]}, Twitter ID: #{row[8]}, FourSquare ID: #{row[9]} already exists"
      puts "****calling of product_build_from_csv*******"
      product = Product.product_build_from_csv(row)
      puts "****End of calling of product_build_from_csv*******"
      product.customer_id = customer.id
      puts "****Going for product validation**********"
      if product.valid?
        puts "****Product is valid**********"
        product.save
        puts "****Product data is saved*******"
      else
        puts "****Product is invalid, error message is going to log file*******"
        Customer.product_error_messages(product)                               
      end      
    end  
    puts "*****Ended the function customer_build_from_csv****"
  end

  private
  #Calling function to write down message in log file
  def self.product_error_messages(product)
    logger = Logger.new('log/logfile.log') 
    logger.info "Product Name:- #{product.errors[:product_name]}" if product.errors[:product_name].any?
    logger.info "Quantity:- #{product.errors[:number_of_items]}" if product.errors[:number_of_items].any?
    logger.info "Amount:- #{product.errors[:amount]}" if product.errors[:amount].any?
    logger.info "Date of purchase:- #{product.errors[:date_of_purchase]}" if product.errors[:date_of_purchase].any? 
  end

end


