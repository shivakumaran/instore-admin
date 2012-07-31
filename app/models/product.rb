class Product
  include Mongoid::Document
  include Mongoid::Timestamps
  #define all fields in the product model
  field :customer_id, :type => Integer
  field :date_of_purchase, :type => String
  field :number_of_items, :type => Integer
  field :product_name, :type => String
  field :amount, :type => Integer
  field :category, :type => String  
  
  #define validation tules
  validates :date_of_purchase, :number_of_items, :product_name, :amount, :presence => true
  
  #define association rule
  belongs_to :customer
  
  #Method called when customer validation is checked and returning one product
  def self.product_build_from_csv(row)
    # find existing customer from email or create new
    puts "****Starting the function of product_build_from_csv*******"
    puts "Initializing products"
    product = Product.new
    puts "Filling up the data in products"
    product.attributes ={:product_name => row[13],
      :date_of_purchase => row[14],
      :number_of_items => row[15],
      :amount => row[16],
      :category => row[17]      
    }    
    return product
    puts "****Returning the product from product_build_from_csv*******"
    puts "****Ending the function of product_build_from_csv*******"
  end
end
