#*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* Plot Class =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*#
#                                                                                                                     #
#  Written by:                                                                                                        #
#             Zach Dischner for personal and LASP scientific uses                                                     #
#  Updated:                                                                                                           #
#             May 1, 2012                                                                                             #
#  Contact:                                                                                                           #
#             zach.dischner@lasp.colorado.edu                                                                         #
#             zach.dischner@gmail.com                                                                                 #
# Purpose:                                                                                                            #
#  The Plot Class has two main tasks:                                                                                 #
#      1. Define methods to query your database to select appropriate data                                            #
#      2. Take that data and dynamically generate HTML/dygraphs logic.                                                #
#      3. Generate Javascript utils for interacting with graphs. This showcases the app's                             #
#           Dynamic ability to employ Javascript capabilities on the fly.                                             #
#                                                                                                                     #
#  Plot HTML templates can be found in the   >>/app/views/layouts/plot_template.html.erb                              #
#  This template defines the proper methodology to implement Plot methods to generate relevant dygraphs HTML.         #
#                                                                                                                     #
#  The general procedure for generating a single dygraphs plot in an HTML page is as follows:                         #
#          1. Appropriate a div for the plot ( "graphdiv#" )                                                          #
#          2. Create a new Javascript dygraphs element ( "g#" )                                                       #
#          3. Generate the header for the graph. This allows a legend to correlate values with variable names         #
#          4. Generate the graph content, or the body of the graph. This parses database values contained in the      #
#             @plot object into a string recognizable by dygraphs functions.                                          #
#          5. Generate dygraphs option specifications for each graph.                                                 #
#          6. Generate linear regression Javascript logic and HTML if wanted.                                         #
#          7. Generate checkbox logic and HTML elements if wanted.                                                    #
#                                                                                                                     #
#  Each of these tasks is made to be dynamic and iterative, so as to provide means to plot any generic dataset.       #
#  Also note that each of these tasks is closely related with the other. Changing one will have a high probability    #
#     changing the others. Javascripts, HTML, and RoR all are inter-related. BEWARE!!!                                #
#                                                                                                                     #
#  On that note, this IS designed to be extremely generic. Changing functionality to fit your specific application    #
#     will likely make more sense eventually. Instead of the current procedure of looping through the @plot object,   #
#     and "send"ing the variable names, you'll know exactly what you want your @plot variable will look like, and what#
#     from it you'll want to plot. Now, this all doesn't really look like OO programming, or a typical RoR app. Once  #
#     you get a more solid base, you should modify the app to behave more like a typical RoR app, if you want to.     #
#                                                                                                                     #
#                                                                                                                     #
# BUGS TO FIX:                                                                                                        #
#     * Slight bug in linear regression rendering for multiple plot windows. Once regressions are calculated and      #
#       drawn in one window, moving to another graph window and calculating a single regression results in that       #
#       regression being correctly drawn, but the previously calculated regression data from the first window also    #
#       gets drawn for the buttons not clicked.                                                                       #
#                                                                                                                     #
#                                                                                                                     #
#                                                                                                                     #
#<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>#

class Plot < ActiveRecord::Base



  #*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* Database Table Specifications =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*#
  # Use these sections to specify some higher level details about your database setup and schema
  # Specify:  *Connection Method                             (Mandatory if not environment default)
  #           *Table Name                                    (Mandatory if not environment default)
  #           *Primary Key                                   (Mandatory if not environment default)
  #           *Whether or not a Filter is to be applied      (optional)
  #           *Several defaults for interaction.             (optional)
  #           *Name of "Date" column variable                (optional)
  #           *Name of integer "X" axis column variable      (optional)
  #           *Name of "filter" column                       (optional)
  #           *Column names to exclude from consideration    (optional)
  #
  # I have provided two databases and their schemas here in this app


  # 1.0-MYSQL development environment
  # recall, to populate, run:    bash$ mysql < {app_dir}/CreateTestTable.txt
  establish_connection :development                        # The connection specs in /config/database.yml
  set_table_name "stock_test"                              # Table name defined in the "CreateTestTable.txt" script
  set_primary_key :id                                      # Table's primary key
  @@find_filter     = true                                 # Indicates that this database will require column filtering (No for unique columns)
  @@default_x       = ["date"]                             # Default selection for X axis
  @@default_y       = ["open","close","adjclose"]          # Default selection(s) for Y axis
  @@default_filter  = ["aapl","arwr","goog","dow"]         # Default selection(s) for FILTER selection
  @@default_feature = ["Both"]                             # Default selection for interaction FEATURE
  @@date_name       = "date"                               # Name of column containing Date values. Set to "" if you wish not to include
  @@index_name      = "id"                                 # Name of column containing some index value
  @@filter_name     = "ticker"                             # Name of column containing filters
  @@exclude_tags    = ["ticker"]                           # Name of columns you don't want to be considered for plotting

  #zZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZzZ

  # 2.0-SQLITE test development environment
  #establish_connection :sqlite_test                     # The connection specs in /config/database.yml
  #set_table_name "plots"                                # Table name defined in the "CreateTestTable.txt" script
  #@@find_filter     = false                             # Indicates that this database will require column filtering (No for unique columns)
  #@@default_x       = [""]                              # Default selection for X axis
  #@@default_y       = [""]                              # Default selection(s) for Y axis
  #@@default_filter  = [""]                              # Default selection(s) for FILTER selection
  #@@default_feature = [""]                              # Default selection for interaction FEATURE
  #@@date_name       = "DataDate"                        # Name of column containing Date values. Set to "" if you wish not to include
  #@@index_name      = "id"                              # Name of column containing some index value
  #@@filter_name     = ""                                # Name of column containing filters
  #@@exclude_tags    = ["created_at","updated_at"]       # Name of columns you don't want to be considered for plotting

  #<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>#


  #=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* Scopes =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*#
  #
  # Scopes to govern the selection of data to be plotted. There are TWO 'classes' of selection methodologies for
  #   basic database operations. More complicated tables will necessitate more complicated selection schemes. It is
  #   recommended that complicated logic regarding data selection be figured out here. That way the user interfaces with
  #   this program the exact same for any level of complication, and logic does not need to be changed throughout the
  #   app.
  # All scopes here are used for database selection in the "app/controllers/plots_controller.rb." The scopes here, and application
  #   logic in that controller are where all data is gathered from the database. Changes here will need to be reflected by
  #   appropriate changes in that controller.
  # The two basic selector 'classes' are as follows:
  #
  #   1. Selections based on ROWS in the database.
  #      eg: " SELECT * FROM table_name WHERE name='some name' "
  #
  #      1.1 DATE SCOPES: Set the @@date_name class variable in the "Database Table Specifications" section above. This
  #                       should be the name of your date-type column in your database
  scope :between_dates, lambda { |start_date, end_date| where(@@date_name +" > ? AND " + @@date_name + " < ?", "#{start_date}", "#{end_date}") }
  scope :after_date, lambda { |start_date| where(@@date_name + " > ?", "%#{start_date}") }
  #
  #
  #      1.2 STRING SCOPES: This is for selection of rows containing certain strings in your database, based on a column
  #                         full of strings.
  #                         EG. if you have a column called "Names" in your database, you want to change "ticker" --> "Names"
  #                         and pass a single name ("Joe", "Sally") to the selector as an argument.
  scope :select_filter, lambda { |filtername| where(@@filter_name + " in (?)", "#{filtername}") }
  #
  #      1.3 NUMERIC SCOPES: "index" is whichever numeric column you want to choose data range with.
  #                     EG. "index" can be 'laps','orbits', or just some index you would want to truncate your dataset by.
  #                         If you have y(x), but don't want to plot y for ALL values of x, use these scopes to truncate
  #                         your dataset.
  scope :after_index, lambda { |x1| where(@@index_name + " >= ?", "#{x1}") }
  scope :before_index, lambda { |x2| where(@@index_name + " <=?", "#{x2}") }
  scope :between_index, lambda { |x1, x2| where(@@index_name + " BETWEEN ? and ?", "#{x1}", "#{x2}") }
  #
  # (1.5) "Filter" selection. This is the optional scope, which depends heavily on your database schema and how you want to plot.
  #         -This will get a list of distinct values in the "filter" column, which can be used in the interaction webpage to obtain
  #          separate datasets.
  #         -Technically, this is still a ROW based selection. However, in its implementation, the "filter" param will be utilized to create
  #          completely different datasets, not provide selection criteria.
  #         -For a stock market database, the user would want to plot stats (in columns) for different stocks.
  #          The stock names are stored in a "tickers" column. So In order to get a list of all tickers so that the
  #          user can make their selection, you can populate a drop down with values gathered from this scope.
  #             eg:     RoR>> @stocks = Plot.select_filter("ticker")
  #             yeilds: ['aapl','goog','arwr',...]
  #          That array can be populated into a drop-down that the user can use to plot stock data based on its ticker.
  scope :get_filter, lambda {|filter| select("DISTINCT #{filter}")}
  #
  #   2. Selections based on COLUMNS in the database.
  #       eg: " SELECT (name,birthday,address) FROM table_name"
  scope :select_var, lambda { |varname| select(varname) }
  #
  # Together, these two scope classes can be layered to create actual database queries
  #       eg:       RoR>> Plot.after_x(4).select_var('z')
  #       becomes:  SQL>> SELECT ('z') FROM Plot where(x>4);
  #
  #=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*#


  #*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* class_var =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
  # Purpose:                                                                                                            #
  #     The following methods provide a means to access class variables outside of the class itself. They also          #
  #     include logic to set these variables by default if they were not assigned in the                                #
  #     "Database Table Specifications" section above. They are used throughout the app and are must be defined         #
  #     at some point. These variables are the only place in the app where you should provide specific information      #
  #     about your database                                                                                             #
  # Inputs:                                                                                                             #
  #     name-the name of your class variable without "@@" signs included                                                #
  # Outputs:                                                                                                            #
  #     @@{class_var}-A class variable that holds some information about this Plot class. These variables SHOULD be     #
  #                   set when defining your database connection.                                                       #
  # Calling:                                                                                                            #
  #         >>my_class_info = @plot.class_var('my_class_variable_name')                                                 #
  # Example:                                                                                                            #
  #     Inside of a controller or view, use this function to fetch some info about your database/schema. For            #
  #     example, to determine if the current connection setup requires "filtering", just call:                          #
  #         >> filter_TorF = @plot.class_var('find_filter?')                                                            #
  #     To get the selections that you would like to be selected by default when the index page is loaded, just:        #
  #         >> X_var_default = @plot.class_var('default_x')                                                             #
  #                                                                                                                     #
  #<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>#
  def class_var(name)
    case name
      when 'filter_name'                                                          # Name of DB 'filter' column
        if !defined? @@filter_name      then @@filter_name      = [""]                       end
        return @@filter_name

      when 'default_x'                                                            # Default 'X' var selection
        if !defined? @@default_x        then @@default_x        = [""]                       end
        return @@default_x

      when 'default_y'                                                            # Default 'Y' var selection(s)
        if !defined? @@default_y        then @@default_y        = [""]                       end
        return @@default_y

      when 'default_filter'                                                       # Default 'Filter' selection(s)
        if !defined? @@default_filter   then @@default_filter   = [""]                       end
        return @@default_filter

      when 'default_feature'                                                      # Default 'Feature' selection
        if !defined? @@default_feature  then @@default_feature  = ["None"]                   end
        return @@default_feature

      when 'date_name'                                                            # Name of 'Date' type column
        if !defined? @@date_name        then @@date_name        = self.find_date_name        end
        return @@date_name

      when 'index_name'                                                           # Name of 'index' variable
        if !defined? @@index_name        then @@index_name       = ""                        end
        return @@index_name

      when 'find_filter?'                                                         # Indicator whether or not the DB schema
        if !defined? @@find_filter      then @@find_filter      = false                      end   # includes a 'filter' type column
        return  @@find_filter


      when 'exclude_tags'                                                         # List of tags to exclude from plotting
        if !defined? @@exclude_tags     then @@exclude_tags     = ['']                       end
        return @@exclude_tags                                                     # Note, these can still be used in logic,
                                                                                  # just not as variables in plotting.
      else
        return name.to_s + " is NOT a valid input"
    end
  end


  #*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* default_selections *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
  # Purpose:                                                                        #
  #     Get default selections for DB interaction. Used in conjunction with:        #
  #      "Plot.class_var", above. The defaults aren't required for the app to       #
  #     function, but this architecture provides a means for easier customization   #
  #     later. If not set in the "Database Table Specifications" above, the         #
  #     this function returns blank strings.                                        #
  # Inputs:                                                                         #
  #     None                                                                        #
  # Outputs:                                                                        #
  #     String/String Arrays. List of variables that you would like to be selected  #
  #                           by default in the query building page. Not necessary  #
  #                           but good for interaction, in case you have a          #
  #                           repeating query.                                      #
  # Calling:                                                                        #
  #          >> x,y,filter,feature = @plot.default_selections()                     #
  # Example:                                                                        #
  #    In the "plots_controller .. index" section, this is used to define the       #
  #    default choices for form elements:                                           #
  #          >> @x_default, @y_default, @filter_default, @feature_default =...      #
  #                                                 ...@plot.default_selections()   #
  #    Then, the "app/views/plots/index.html.erb" page will use the above defined   #
  #    variables to fill in form selections upon loading of the page                #
  #                                                                                 #
  #<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>#
  def default_selections()
    # figure out how to default to " "
    d_x       = self.class_var('default_x')
    d_y       = self.class_var('default_y')
    d_filter  = self.class_var('default_filter')
    d_feature = self.class_var('default_feature')

    return d_x,d_y,d_filter,d_feature
  end


  #*=*=*=*=*=*=*=*=*=*=*=*=*=*=* year_bounds *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*#
  # Purpose:                                                                  #
  #     Simply return the earliest or latest year available in the database.  #
  # Inputs:                                                                   #
  #     condition-String. Keyed to get first/last year available              #
  # Outputs:                                                                  #
  #     Integer-Year number in standard form                                  #
  # Calling:                                                                  #
  #          >> year = Plot.year_bounds('first')                              #
  # Example:                                                                  #
  #    In the "plots/index.html.erb" view, this function is called within the #
  #    "date_select" helper options to define a starting year and ending      #
  #    year to be populated in the drop down list. Not necessary, but helpful #
  #       <%= date_select(:date_end, params[:date_end],                       #
  #                 :start_year  => Plot.year_bounds('first'),                #
  #                 :end_year    => Plot.year_bounds('last'), ...             #
  #                                                                           #
  #<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>#
  def self.year_bounds(condition)
    if defined? @@date_name then
      if condition.downcase == 'first' then
        find(:first, :order => @@date_name + " ASC").send(@@date_name).to_date.year
      elsif condition.downcase == 'last'
        find(:first, :order => @@date_name + " DESC").send(@@date_name).to_date.year
      end
    end

  end

  #*=*=*=*=*=*=*=*=*=*=*=*=*=*=* find_date_name =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*#
  # Purpose:                                                                  #
  #     Try to determine whether the database has a date type column. Very    #
  #     crude, just tries to see if the column name matches 'date'.           #
  #     Basically, if the programmer does as they are supposed to, and tells  #
  #     RoR what the @@date_name is, even if there is no date (""), this      #
  #     method will never be used. It is just here in case of negligence.     #
  # Inputs:                                                                   #
  #     None                                                                  #
  # Outputs:                                                                  #
  #     date_name-The name of Rails' best guess at what variable is a date    #
  #               type in you database.     '                                 #
  # Calling:                                                                  #
  #          >> date_name = Plot.first.find_date_name                         #
  # Example:                                                                  #
  #    When searching for the @@date_name class variable, if it is undefined  #
  #    try this function to determine if there is a 'date' named column in    #
  #    your database. See the   {Plot.class_var} section above                #
  #       >>if !defined? @@date_name then @@date_name =                       #
  #                                       Plot.first.find_date_name           #
  #                                                                           #
  #<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>#
  def find_date_name()
    date_name = ""
    vars = self.list_vars() - self.class_var('exclude_tags')

    # Will not work very well if you have multiple fields with "*date*" in
    # the name. It will just choose the last one.
    vars.each do |var|
      if !var.match("[Dd]ate").nil? or self.send(var).class.in? [Date,ActiveSupport::TimeWithZone] then
        date_name = var
      end
    end



  return date_name

  end




  ##############################################################################################################################
  #>>>>>>>>>>>>>>>>>>> Everything Below this line shouldn't be changed unless you know what you're doing  <<<<<<<<<<<<<<<<<<<<<#
  ##############################################################################################################################




  #*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*= all_checkboxes_true  *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*#
  # Purpose:                                                                              #
  #     Generate list of true/false strings. Not complicated, just replicates             #
  #     'true' or 'false' for placement in dygraphs options                               #
  # Inputs:                                                                               #
  #     list: Array of strings. Each of which represents an individual line to be         #
  #           plotted                                                                     #
  # Outputs:                                                                              #
  #     String. HTML formatted list of 'true's to use when initially setting line         #
  #     visibility/checkbox selection                                                     #
  # Calling:                                                                              #
  #         >> @plot.first.all_checkboxes_true(params[:y_var])                            #
  #     Makes a list of 'true' for each member of params[:y_var]                          #
  # Example:                                                                              #
  #     If the Y variables of a plot are contained within an array as:                    #
  #         >>params[:y_var] = ['y1','y2']                                                #
  #     Then inside the method >>dygraph_options() (or if relocated directly to a view)   #
  #         visibility: <%=                                                               #
  #                 render :inline => @plot.first.all_checkboxes_true(params[:y_var])     #
  #                      %>                                                               #
  #     When used in conjunction with checkboxes, this marks which plot lines are         #
  #     visibly when the plot shows up, and which are not.                                #
  #                                                                                       #
  #<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>#
  def all_checkboxes_true(list)
    return (["true"]*(list.length-1)).to_s
  end



  #*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*= all_checkboxes_false  *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
  #  Same as >>all_checkbox_true() except that using this function turns all plots
  #  off initially
  #<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>#
  def all_checkboxes_false(list)
    return (["false"]*(list.length-1)).to_s
  end


  #*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* convert_date  *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*#
  # Purpose:                                                                              #
  #     Converts the dates selected using a RoR date selector drop down into a date       #
  #     format that can be used to query a Database.                                      #
  #     This can be easily modified/duplicated to work for DATETIME type objects. The     #
  #      general form is the same, just add a few more components to the logic below      #
  # Inputs:                                                                               #
  #     date_obj: A date hash, populated from drop-down menus in a view, which contains a #
  #          Year, Month, and Day element. These elements are stored in the               #
  #          ['(1i)','(2i)','(3i)'] keys. Expects the results from a RoR                  #
  #          "date_select" helper                                                         #
  # Outputs:                                                                              #
  #     RoR Date object which can be used to query the database.                          #
  # Calling:                                                                              #
  #         >> @plot.first.convert_date(date_hash)                                        #
  # Example:                                                                              #
  #     From the "date_select" helper, a date hash will be populated to look like:        #
  #         >>params[:my_date]={'(1i)'=>2012,'(2i)' => 6, '(3i)' => 24}                   #
  #     To convert this hash into a Ruby "Date" class, just pass it through this function.#
  #         >>R_date = @plot.first.convert_date(params[:my_date])                         #
  # Note:                                                                                 #
  #     For some reason, this appears to be an erroneous statement in some editors. But   #
  #     it still works, so the validity of the error statement is questionable.           #
  #<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>#

  def convert_date(date_obj)
    return Date.new(date_obj['(1i)'].to_i, date_obj['(2i)'].to_i, date_obj['(3i)'].to_i)
  end



  #*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* date_invalid  *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*#
  # Purpose:                                                                              #
  #     Performs a check on a date object, to see whether or not any component of it is   #
  #     blank.                                                                            #
  #     This can be easily modified/duplicated to work for DATETIME type objects. The     #
  #      general form is the same, just add a few more components to the logic below      #
  # Inputs:                                                                               #
  #     date_obj: A date hash, populated from drop-down menus in a view, which contains a #
  #          Year, Month, and Day element. These elements are stored in the               #
  #          ['(1i)','(2i)','(3i)'] keys. Expects the results from a RoR                  #
  #          "date_select" helper                                                         #
  # Outputs:                                                                              #
  #     Boolean True/False indicator. Returns true if the date is invalid                 #
  # Calling:                                                                              #
  #         >> @plot.first.date_invalid(date_hash)                                        #
  # Example:                                                                              #
  #     From the "date_select" helper, a date hash will be populated to look like:        #
  #         >>params[:my_date]={'(1i)'=>2012,'(2i)' => 6, '(3i)' => 24}                   #
  #     To see if this is a valid date selection, run:                                    #
  #         >>bad_date = @plot.first.date_invalid(params[:my_date])                       #
  #                                                                                       #
  #<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>#
  def date_invalid(date_obj)
    if self.class_var("date_name") != "" then
      return ([date_obj["(1i)"].to_s.blank?, date_obj["(2i)"].to_s.blank?, date_obj["(3i)"].to_s.blank?]).include?(true)
    else
      return true
    end
  end



  #*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* dygraph_head  *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*#
  # Purpose:                                                                              #
  #     Generate the header (first line) of the argument input to dygraphs function in    #
  #       an html page. This line holds the names of datasets being plotted. See the      #
  #       plot templates in "views/layouts/plot_*"                                        #
  # Inputs:                                                                               #
  #     tags: An array of string values, corresponding to the [x,y1,y2,y3...] variable     #
  #          names as will displayed in the dygraphs legend.                              #
  # Outputs:                                                                              #
  #     labelstring: Dygraph string. Used in first line of Dygraphs plot generation       #
  #                  containing plot variable names                                       #
  # Calling:                                                                              #
  #         >> @plot.first.dygraph_head(@Tag_Values)                                      #
  #     Returns the @Tag_Values to html calling page, formatted for dygraph input         #
  # Example:                                                                              #
  #     In a new dygraph element in HTML page:                                            #
  #          >> g=new Dygraph(...                                                         #
  #                 <%= putc(@plot.first.dygraph_head(@tags)) %>                          #
  #     This turns something like:                                                        #
  #         >> @tags = ["date","y1","y2"]                                                 #
  #     to dygraphs expected format:                                                      #
  #         >> {above} ==> "'date,y1,y1\n'+ "                                             #
  #                                                                                       #
  #<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>#
  def dygraph_head(tags)
    labelstring = ",'"
    for ii in 0..(tags.length-1)
      labelstring += tags[ii].to_s
      labelstring += ',' unless (ii==(tags.length-1))
    end
    labelstring += '\n' +"'+"

    return labelstring
  end

  #*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* dygraph_body  *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*#
  # Purpose:                                                                              #
  #     Similar to "Plot.dygraph_head", this generates the body, or numeric portion of    #
  #       Dygraph function input in an html page. Basically, parses the @plot object      #
  #       into numeric strings formatted for dygraphs functions.                          #
  #        See the plot templates in "views/layouts/plot_*"                               #
  # Inputs:                                                                               #
  #     tags: Array of strings. Each tag is the name of a @plot attribute to be plotted   #
  #     values: @plot instance variable, whose attributes are the variables to be plotted #
  #             by Dygraphs.                                                              #
  # Outputs:                                                                              #
  #     body_string: Dygraph string. The 'meat and potatoes' of the Dygraph plotting      #
  #                  input. This string contains a list of all values to be plotted       #
  # Calling:                                                                              #
  #         >> @plot.first.dygraph_body(@Tag_Values,@Plot_Values)                         #
  #     Returns the @Plot_Values with @Tag_Values attributes to html calling page,        #
  #     formatted for dygraph input                                                       #
  # Example:                                                                              #
  #     In a new dygraph element in HTML page:                                            #
  #          >> g=new Dygraph(...                                                         #
  #                 <%= putc(@plot.first.dygraph_head(@tags)) %>                          #
  #                 <%= putc(@plot.first.dygraph_body(@tags,@plot)) %>                    #
  #     This turns something like:                                                        #
  #         >> @tags = ["date","y1","y2"]                                                 #
  #         >> @plot --> Plot date:'2012-01-01', y1:1, y2:35 ...                          #
  #     to dygraphs expected format:                                                      #
  #         >> {above} ==> "'date,y1,y2\n' + '2012-01-01,1,35\n' + " ...                  #
  #     in conjunction, "Plot.dygraph_head" and "Plot.dygraph_body" parse the             #
  #     ActiveRecord @plot object into what Dygraphs functions expect                     #
  #                                                                                       #
  #<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>#
  def dygraph_body(tags, values)
    body_string = ''
    values.each do |value|
      ; # for each row in the @plot selection
      body_string += "'"
      for ii in 0..(tags.length-1) # for each tag (column) in that row
        body_string += (value.send(tags[ii].to_s)).to_s
        body_string += ',' unless (ii==(tags.length-1))
      end # End format is <   'x_value,y_value,y2_value,y3_value\n' +  >
      body_string += '\n' + "'"
      body_string += "   +" unless value==values.last
    end
    return body_string
  end


  #*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* dygraph_options  *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
  # Purpose:                                                                              #
  #     This function simply returns the Dygraphs options to the calling HTML page.       #
  #       Most of this is static, and doesn't need to be in a function, but it reduces    #
  #       clutter in HTML pages and makes graph stylizing and modification easier.        #
  #     In addition, placing this function here lets the options be customized for EACH   #
  #       plot window. You may want to specify different colors, options, ect for         #
  #       different "graphnum" inputs. As is, the "graphnum" input simply allows each     #
  #       window of plot data to behave independently of one another. The "graphnum"      #
  #       variable should mirror the "graphdivX" labeling used in the view for            #
  #       Dygraphs instantiation.                                                         #
  # Inputs:                                                                               #
  #     graphnum (optional): Integer Input The plot window that the returned options      #
  #                          correspond to.                                               #
  #                          "graphnum" should mirror the  Dygraphs instantiation         #
  #                         of "graphdivX" inside the view. See the plot_template.html    #
  #                         page for more information.                                    #
  #     lin_reg (optional): Indicator whether or not the user has asked for linear        #
  #                         regression functionality to be added to the plot. If not set, #
  #                         the Dygraphs function, "underlayCallback", interferes with    #
  #                         plotting. Can't be included since the rest of the             #
  #                         functionality isn't included                                  #
  # Outputs:                                                                              #
  #     options_string: String. Dygraphs string that is an input to the Dygraphs plotting #
  #                             function. Specifies the options for that plot.            #
  # Calling:                                                                              #
  #         >> @plot.first.dygraph_options(OptionalNumber)                                #
  #     Returns string to html page that specifies options for Dygraph plot window        #
  # Example:                                                                              #
  #     In a new dygraph element in HTML page:                                            #
  #         >> g=new Dygraph(...                                                          #
  #         >>     <%= putc(@plot.first.dygraph_head(@tags)) %>                           #
  #         >>     <%= putc(@plot.first.dygraph_body(@tags,@plot)) %>                     #
  #         >>     <%= render :inline => @plot.first.dygraph_options(graphnum)  %>        #
  #     This concludes inputs to Dygraph function. 1:header, 2: body:, 3:options. The     #
  #       options have been formatted to apply to just a single graph window.             #
  #                                                                                       #
  #<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>#
  def dygraph_options(graphnum="", lin_reg="false")
    options_string =
        ",{
          height: 375,                                                               // Specifies the Height of the plot area
          width: 700,                                                                // Specifies the Width of the plot area
          hideOverlayOnMouseOut: false,                                              // Keeps the legend visible at all times
          showRoller: true,                                                          // Show a rolling Average box
          rollPeriod: 1,                                                             // Set default average for rolling average (0 means no average...)
          labelsDivWidth: 100,                                                       // Set the
          labelsDiv: document.getElementById('Legend_Div" + graphnum.to_s + "'),     // Specifies External Div to put Legend Labels in
          labelsSeparateLines: true,                                                 // Different lines per label for easier readability
          "

    options_string += "underlayCallback: drawLines" + graphnum.to_s + ",        // MUST enable this  to show linear regression
           " unless !lin_reg


    options_string += "xlabel: '<%=params[:x_var]%>',                          // Label for the X axis
          ylabel: '<%=render :inline => params[:y_var].to_s %>',                     // Labels for the Y axis
          visibility: <%= render :inline => @plot.first.all_checkboxes_true(params[:y_var]) %>   // Initial visibility of plot lines
        } "
    return options_string
  end



  #*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*= list_vars =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*#
    # Purpose:                                                                  #
    #     Return an array of attribute names as strings.                        #
    # Inputs:                                                                   #
    #     None                                                                  #
    # Outputs:                                                                  #
    #     vars: Array of strings containing collected object attributes         #
    # Calling:                                                                  #
    #          >> my_varnames = @plot.list_vars                                 #
    # Example:                                                                  #
    #    If you have an instantiation with variables like:                      #
    #          >> @plot.x @plot.y @plot.z                                       #
    #    You can get a list of all attributes by calling:                       #
    #          >> @plot.first.list_vars                                         #
    #    which returns an array consisting of:                                  #
    #          =>["x","y","z"]                                                  #
    #                                                                           #
    #<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>#
    def list_vars
      atts = self.attributes
      vars = []
      atts.each { |att| vars.concat([att[0]]) }
      return vars
    end

 


    #*=*=*=*=*=*=*=*=*=*=*=*=*=*=*= put_checkboxes =*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
    # Purpose:                                                                  #
    #     Dynamically generate HTML for checkboxes. These will provide the      #
    #     user with a quick way to toggle multiple plot sets on the current     #
    #     chart.                                                                #
    #     *Note that this is HTML, that is tied to DYGRAPHS functionality.      #
    #     Modify appropriately                                                  #
    # Inputs:                                                                   #
    #     list-an array of strings tied to the Y axis variables for each plot   #
    #          window.                                                          #
    #     {graphnum}-Optional input, ties the checkbox to a single window. This #
    #                way,for plots with multiple windows, a checkbox only turns #
    #                on/off lines for that window                               #
    # Outputs:                                                                  #
    #    boxstring: String. HTML formatted string tying HTML checkboxes to      #
    #               individual plot lines.                                      #
    # Calling:                                                                  #
    #         >> @plot.first.put_checkboxes(y_vars)                             #
    #     This dynamically makes HTML that activates a check box for each of    #
    #     the y_var strings.                                                    #
    # Example:                                                                  #
    #     If the Y variables of a plot are contained within an array as:        #
    #         >>params[:y_var] = ['y1','y2']                                    #
    #     Then inside a view:  #                                                #
    #         <%=render :inline => @plot.first.put_checkboxes(params[:y_var])%> #
    #     *Note that this function returns a formatted string. So in order to   #
    #     use the string inside the view, you must use the protocol:            #
    #          render :inline =>                                                #
    #                                                                           #
    #<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>#
    def put_checkboxes(list,graphnum="")
      boxstring = '' #
      for ii in 0..(list.length-1)
        boxstring += "<input type=checkbox id='" + ii.to_s + "' checked onClick='change"+graphnum.to_s+"(this)'> \n"
        boxstring += "<label for='" + ii.to_s + "'>" + list[ii] + " </label>" + "<br/>" unless (ii == list.length)
      end
      boxstring += '</p>'
      return boxstring
    end


  #*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*= linear_reg  *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
  # Purpose:                                                                              #
  #     This function returns javascript functions and utilities that enable the          #
  #     calculation, displaying, and drawing of linear regression fits for plotted        #
  #     data sets. While not spectacularly useful, this functionality shows how easily    #
  #     dynamic interaction and data manipulation of graph data can be implemented.       #
  #     Each time it is called, this function creates a whole new set of javascript       #
  #     functions, tailored to an individual graph window.                                #
  #     Again, all these functions are designed to be tied to dynamically named graph     #
  #     windows, activation buttons, and div's in order to work. Proper cross referencing #
  #     simply depends on keeping the "graphnum" variable constant in calling.            #
  # Inputs:                                                                               #
  #     graphnum (optional)-Integer. The particular graph window that the regression      #
  #                         functions will be tied to                                     #
  #                         Again, "graphnum" should mirror the  Dygraphs instantiation   #
  #                         of "graphdivX" inside the view. See the plot_template.html    #
  #                         page for more information.                                    #
  # Outputs:                                                                              #
  #     linear_reg_str-String. Contains Javascript code and function definitions.         #
  #                    Together, they represent all utilities needed for regression       #
  #                    functionality.                                                     #
  # Calling:                                                                              #
  #     >>@plot.first.linear_reg(graph_number)                                            #
  # Example:                                                                              #
  #      In a view, to enable linear regression functionality for a particular graph      #
  #      window, just call this function with the corresponding window number             #
  #         >> regression_functions = @plot.first.linear_reg(0)                           #
  #      generates functions tied to the graph window 0 (graphdiv0) and the corresponding #
  #      HTML elements required for activation.                                           #
  #      As before, implementation requires live rendering of this string:                #
  #         >> render :inline => regression_functions                                     #
  #                                                                                       #
  # NOTE:                                                                                 #
  #      Much of this I took from an online open source. It has since been modified and   #
  #      I have added features and functions of my own, but at its core it is the same as #
  #      is offered from the Dygraphs website.                                            #
  #                                                                                       #
  #<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>#

  def linear_reg(graphnum = "")
    linear_reg_str ='// coefficients of regression for each series.
      // if coeffs = [ null, [1, 2], null ] then we draw a regression for series 1
      // only. The regression line is y = 1 + 2 * x.
      var coeffs = [ null, null, null ];
      function regression' + graphnum.to_s + '(series) {
        // Only run the regression over visible points.
        var range = g' + graphnum.to_s + '.xAxisRange();

        var sum_xy = 0.0, sum_x = 0.0, sum_y = 0.0, sum_x2 = 0.0, num = 0;
        for (var i = 0; i < g' + graphnum.to_s + '.numRows(); i++) {
          var x = g' + graphnum.to_s + '.getValue(i, 0);
          if (x < range[0] || x > range[1]) continue;

          var y = g' + graphnum.to_s + '.getValue(i, series);
          if (y == null) continue;
          if (y.length == 2) {
            // using fractions
            y = y[0] / y[1];
          }

          num++;
          sum_x += x;
          sum_y += y;
          sum_xy += x * y;
          sum_x2 += x * x;
        }

        var a = (sum_xy - sum_x * sum_y / num) / (sum_x2 - sum_x * sum_x / num);
        var b = (sum_y - a * sum_x) / num;

        coeffs[series] = [b, a];
        if (typeof(console) != ' + "'" + 'undefined' + "'" + ') {
          console.log("coeffs(" + series + "): [" + b + ", " + a + "]");
        }

        g' + graphnum.to_s + '.updateOptions({});  // forces a redraw.

        // Every time the regressions are calculated, call the printing function
        //    that will output the coefficients of the given linear regression to
        //    the HTML page. This function is tied to existing <div> spaces in the
        //    HTML page.
        print_Coeffs' + graphnum.to_s + '(series);

      }

      function clearLines' + graphnum.to_s + '()
      {
        for (var i = 0; i < coeffs.length; i++)
        {
          coeffs[i] = null;
        }
        g' + graphnum.to_s + '.updateOptions({});
        clear_Coeffs' + graphnum.to_s + '()

      }


      function drawLines' + graphnum.to_s + '(ctx, area, layout) {
        if (typeof(g' + graphnum.to_s + ') == ' + "'" + 'undefined' + "'" + ') return;  // wont be set on the initial draw.

        var range = g' + graphnum.to_s + '.xAxisRange();
        for (var i = 0; i < coeffs.length; i++) {
          if (!coeffs[i]) continue;
          var a = coeffs[i][1];
          var b = coeffs[i][0];

          var x1 = range[0];
          var y1 = a * x1 + b;
          var x2 = range[1];
          var y2 = a * x2 + b;

          var p1 = g' + graphnum.to_s + '.toDomCoords(x1, y1);
          var p2 = g' + graphnum.to_s + '.toDomCoords(x2, y2);

          var c = new RGBColor(g' + graphnum.to_s + '.getColors()[i - 1]);
          c.r = Math.floor(255 - 0.5 * (255 - c.r));
          c.g = Math.floor(255 - 0.5 * (255 - c.g));
          c.b = Math.floor(255 - 0.5 * (255 - c.b));
          var color = c.toHex();
          ctx.save();
          ctx.strokeStyle = color;
          ctx.lineWidth = 1.0;
          ctx.beginPath();
          ctx.moveTo(p1[0], p1[1]);
          ctx.lineTo(p2[0], p2[1]);
          ctx.closePath();
          ctx.stroke();
          ctx.restore();
        }
      }


      // Here is my function to format and return Linear Regression Coefficients
      //    It places a formatted string of coefficients in the appropriately named
      //    <div>. Dynamic naming of each line series space as <div_0> , <div_1>
      //    etc is required for this to work. That way, each time a regression is
      //    calculated for a series (0,1,2...), the matching coefficient calculation
      //    will be put in the like-named divs. A similar function is also below to
      //    clear the appropriate coefficient strings when the linear regressions
      //    themselves are cleared.

      // IMPORTANT!!! TO PRINT COEFFICIENTS, THIS FUNCTION MULTIPLY BY -1,
      // THAT IS DUE TO THE PARTICULAR DATABASE ORDER BEING USED WHERE "NEWER"
      // SETS HAVE LOWER IDs. THIS IS COMPLETELY DATABASE DEPENDANT.

     function print_Coeffs' + graphnum.to_s + '(ii)
        {
          var reg = coeffs[ii];
          var reg_str = "Coefficients are : <br>"
          reg_str += "y =  [" + -1*Math.round(reg[0]*1000)/1000 + "] x  + [" + -1*Math.round(reg[1]*1000)/1000 + "] </br>"
          document.getElementById("Div_' + graphnum.to_s + '" + ii).innerHTML = reg_str;
        }

      function clear_Coeffs' + graphnum.to_s + '(ii)
        {
          for (var i = 1; i < coeffs.length; i++) document.getElementById("Div_' + graphnum.to_s + '" + i).innerHTML = "Coefficients are:";
        }
      '
    return linear_reg_str
  end





  #*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*= linear_reg_buttons  *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#
  # Purpose:                                                                              #
  #     This function returns HTML formatted strings that, when rendered in a view, will  #
  #       1. create a button linked to each line in the corresponding plot window.        #
  #       2. create a DIV linked to each line in the corresponding plot window            #
  #     Clicking the button will generate and plot a linear regression for its            #
  #       associated dataset, and print the coefficients of that regression inside the    #
  #       newly created DIV. Both are rendered live to call other Javascript functions    #
  #       that handle these two actions.                                                  #
  #     Note that the "graphnum" variable must be the same for all applicable functions.  #
  #     HTML elements, Javascript operations and internal calculations depend on this     #
  #     variable being constant throughout.                                               #
  # Inputs:                                                                               #
  #     list-String. Array of variable names that will be tied to Linear Regression       #
  #          generation buttons                                                           #
  #     graphnum (optional)-Integer. The particular graph window that the buttons will be #
  #                         connected to                                                  #
  #                         Again, "graphnum" should mirror the  Dygraphs instantiation   #
  #                         of "graphdivX" inside the view. See the plot_template.html    #
  #                         page for more information.                                    #
  # Outputs:                                                                              #
  #     button_str- String. HTML  formatted string that, when rendered, will create       #
  #                 buttons in an HTML page that activate linear regression functionality #
  # Calling:                                                                              #
  #     >>@plot.first.linear_reg_buttons(my_list,graph_number)                            #
  # Example:                                                                              #
  #      Given a list of variables being plotted, the HTML for a button for each of       #
  #      those variables will be created and returned as a single string.                 #
  #         >> params[:y_var] = ['y1','y2','y3']                                          #
  #         >> button_code = @plot.first.linear_reg_buttons(params[:y_var])               #
  #      For plots with multiple graph windows, the appropriate window must also be       #
  #      into this function's calling                                                     #
  #      In practice, this code must then be rendered live in the VIEW it is being called #
  #      in                                                                               #
  #         >> render :inline => button_code                                              #
  #      Now each button is tied to a single line in the appropriate graph window, and    #
  #      is set to activate javascript functions that will analyze that line, report      #
  #      its coefficients, and draw the newly created linear fit.                         #
  #                                                                                       #
  #<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>#
  def linear_reg_buttons(list, graphnum="")
    button_str = ''
    for ii in 0..list.length-1
      button_str += '<input type=button style="color:RGBColor(g' + graphnum.to_s + '.getColors().[' + ii.to_s + ']).toHex;" value="Regression For --> ' + list[ii] + '"
                                    onClick="regression' + graphnum.to_s + '(' + (ii + 1).to_s + '), coeffs_' + (ii+1).to_s + '()" />' + "\n"
      button_str += '<br/><div style="padding:5px; border:2px solid black" id="Div_' + graphnum.to_s + (ii+1).to_s + '">Coefficients are: </div><br/>' + "\n"
    end
    button_str += '<input type=button value="Clear Lines" onClick="clearLines' + graphnum.to_s + '()" />' + "\n"
    #button_str += '</div>'   + "\n"
    return button_str
  end



end

#*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* Some Additional Notes =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*#
#
#
#
# 1.0  For this app to work, "app/assets" MUST have "dygraph-combined.js". Tricky to catch
#
# 2.0  Many of the above functions are not especially useful or smart. I just made them this way in
#      the name of explicitness, and isolation, so that all real logic is housed in this class. Especially
#      when you know what your datasets will look like, many of these methods can be simplified or removed. In addition
#      isolating everything in this way will hopefully make it easier to port this design to other architectures. I have
#      ambition to someday try to convert this project to a Django one.
#
# 3.0  Many methods feature an odd mix of HTML, Javascript, and RoR. It works, provided you follow the
#      outlines in the "app/views/layouts/plot_template.html.erb" layout, but is not especially pretty, or easy to grasp
#      initially. Again, this approach was mostly chosen for isolation purposes. As well as my desire for
#      this class to handle ALL application logic, even though Javascript and HTML on the pages themselves
#      could do much if not all of the logic.
#
#  4.0 This is not a typical Rails app. It doesn't utilize objects the same as many standard apps should. This was due to a
#      few things.
#      I'm not a rails master. In fact, this is my first rails app, my first experience with HTML, web design,
#      ruby, and my first attempt at Object-Oriented programming in general. As such, I'm probably pretty bad at it, and
#      the design of this application seems to violate many hard-and-fast practices of OO programming.
#      All of the methods below act more like FUNCTIONS. In fact, nothing about this 'class' resembles an object. The reason
#      for this is that this application is meant to work generically on any DATASET. This brings about problems:
#    4.1. Since the app is not designed around any specific database model, its logic can't be aware of the database
#         schema or elements. Methods and operations must perform their tasks without being concious of what they are
#         operating on.
#    4.2. By working with just raw random data, returns from the database are really more of data STRUCTURES, rather
#         than specific data OBJECTS. It makes no sense to try and think about these returns as objects. Without knowing
#         anything about the data, its useless to try and form it all into objects. Its like calling it a "Thing", and
#         saying that "Thing" has other "things", and can do "stuff".
#    4.3. Even if we knew what kind of data we are fetching, we really aren't fetching objects. We're fetching a big hunk
#         of (mainly) numeric data.
#         Both of these reasons point towards treating data as structures, and performing procedural operations on that data.
#         So this app is designed around that notion. But hey, I'm a noob. I could be totally wrong and its just my desire
#         to default back to a MATLAB mindset!
#         Either way, I designed all of these methods to work on arbitrary datasets. I did it this way for flexibility,
#         modularity, and ease of comprehension. They could (and should) easily be modified to have more Object-like
#         behavior once you implement yourself.
#
#  5.0  This app shares many @instance_variables between controller and views. This is un-advisable for some reason.
#       Don't know the exact reason, but the fact remains this is a practice to avoid. I did not avoid it, so a more
#       competent Rails programmer may want to fix this.
#
#
#
#
#

#*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* Plans for the Future *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*#
#
# 1.0: The next simple database schema that makes sense to me would be to have one database, and many tables. Envision
#      multiple observers, each with their own table of observations. Essentially, this would be the same idea as having
#      a 'filter'. Instead of having one large table, with sets of rows representing each 'filter's data points,
#      you'd have many tables of independent data.
#      I don't envision this being extremely difficult. I think the 'filter' idea can remain the same. But, instead of
#      running multiple queries on the same databases for each 'filter' variable, the app could change its table-name
#      on the fly, and just run the same query for different tables. I think:
#        >> set_table_name "new_table"
#      could be added to the plots_controller, or to a method inside of the model. I just don't have a database like
#      this to test the idea yet.
#
# 2.0: I don't especially like the wayDygraphs parsing is now. Every filter selection gets its own separate query and
#      its own @instance variable. Then, to parse the data into Dygraphs format, each @tag is 'sent' to that variable.
#      Its kinda a wishy washy procedure. At some point, I would like for the fetched variable to be turned into a
#      hash, which can be sorted and worked with on the fly. The same idea of 'sending' variable names will still work,
#      but now it will be in a hash. In addition, instead of sending @tags, sending params[:x_var] and params[:y_var]
#      will be more robust.
#      The hash would also allow all fetched data to be placed in a single variable, instead of the current method of
#      populating separate @instance variables for each db query. #
#
#


