class WelcomeController < ApplicationController
  def index
    if @curr_user.is_admin
      @users = @curr_user.organisation.users
      @venues = @curr_user.organisation.venues.where(:archive => false).limit(5)
      @venue_checkin = []
      @venues.each do|venue|
        begin
        res=venue.search_from_four_square_api(Hash[:venue_id=>venue.access_code],"access_id")
        @venue_checkin << [venue,res]
        rescue
        end  
      end
      # @graph = open_flash_chart_object(700,400,"/welcome/graph_code")
    else
      redirect_to organisations_path
    end
  end
  
  def graph_code
    @venues = @curr_user.organisation.venues.limit(10)
    title = Title.new("Venues Checkin Count")
    bar = BarGlass.new
    
    # NOTE ... the next two lines are if you want each bar to have a different response when clicked
    bar_values = (1..9).to_a.map{|x| bv = BarValue.new(x); bv.on_click = "alert('hello, my value is #{x}')"; bv}
    bar.set_values(bar_values)
    
    # if you want a more generic response across all bars, then the following lines would do:
    # bar.on_click = "alert('hello there')"
    # bar.set_values((1..9).to_a)
    chart = OpenFlashChart.new
    chart.set_title(title)
    chart.add_element(bar)
    
    x = XAxis.new
    x.set_offset(true)
    x.set_labels(@curr_user.organisation.venues.limit(9).collect{|v|v.name})
    x.rotate = 90
    chart.set_x_axis(x)
    
    # labels = XAxisLabels.new
    # labels.text = "#date: l jS, M Y#"
    # labels.steps = 86400
    # labels.visible_steps = 2
    # labels.rotate = 90
# 
    # x.labels = labels    

    y = YAxis.new
    y.set_offset(false)
    y.set_range(0,30)
    chart.set_y_axis(y)
        
    render :text => chart.to_s
  end
  
  def insufficient_privilege
    
  end
end
