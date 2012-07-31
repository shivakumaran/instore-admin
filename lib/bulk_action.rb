#This class is used for initailization of different actions (enabling, disabling, delete)
#and defining of that actions

class BulkAction
  
  #Initialize method to initialize model name, action name and checked ids from check boxes
  def initialize(model_name, bulk_action, checked_ids)
    @model = model_name
    @action_name = bulk_action
    @checked_ids = checked_ids    
  end
  
  #Defining method for updation of enable/disable status OR archive status for records
  #those are selected during enable/disable/delete operations from organisation/users/venues
  def bulk_action_method   
    unless @checked_ids.blank?
      @checked_ids.each do |checked_id|
        checked_record = @model.find(checked_id)          
          case @action_name
            when "Delete"
              checked_record.update_attribute(:archive, "true")             
              if @model.to_s == "Organisation"               
                checked_record.users.first.update_attributes(:disabled => "true", :archive => "true") unless checked_record.users.blank?
              end
            when "Enable"
              checked_record.update_attribute(:disabled, "false")
            when "Disable"
              checked_record.update_attribute(:disabled, "true")
          end          
      end
     end    
  end
end
