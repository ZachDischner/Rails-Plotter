#*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*  PlotsController =*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*#
#                                                                                                                   #
# This controller handles the fetching and organization of data from the database, and then routing that data       #
#   into the correct VIEW pages.                                                                                    #
# As of now, there are two pages associated with the plotting app.                                                  #
#   1. Index.html.erb. This page creates a table full of options that allows the user to select criteria used for   #
#      database querying and data collection.                                                                       #
#   2. plotter.html.erb. This page dynamically takes the users selection data criteria, and renders that data into  #
#      interactive and totally fun graph windows.                                                                   #
#                                                                                                                   #
#*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*#

class PlotsController < ApplicationController

  #*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*  index  *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*#
  #                                                                                                                   #
  # Purpose:                                                                                                          #
  #     The INDEX method is responsible for fetching and handling the information needed to build a form that the     #
  #     user will use to select plot criteria. Its tasks are as follows:                                              #
  #                                                                                                                   #
  #     1.0-Fetch single row from the database. This set is examined and used to build the form later.                #
  #                                                                                                                   #
  #     2.0-Get list of all variables (database columns) in that selection.                                           #
  #                                                                                                                   #
  #     3.0-Get list of variables that are to be EXCLUDED from the user interface.                                    #
  #                                                                                                                   #
  #     4.0-Get the default selections for each form field. These values will be implemented upon loading the page    #
  #                                                                                                                   #
  #*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*#
  def index
    # Used in the "index" page to activate helper popups that help in development.
    # Set to 'false' if you no longer wish to view these helpers.
    params[:debug] = true

    # Get a single row of info from the database around which to build the user interface
    @plot=Plot.first

    # Get a list of all variable names
    vars = @plot.list_vars

    # These tags are to be excluded from any interactions, as they are database utilities, strings, or
    # otherwise unplottable data.
    exclude_tags = @plot.class_var('exclude_tags')

    vars.each do |var|
      exclude_tags += [var] unless @plot.send(var).class != String
    end
    exclude_tags = Array(exclude_tags) - Array(@plot.class_var('date_name'))

    # Get an array of the collected data as an array of strings. This will be used throughout plotting
    @tags = @plot.list_vars - exclude_tags

    # Get Filters, add a "No Filter" option for fast implementation of databases without need for filtering.
    # Ideally, this is all taken out later for such applications.
    @filters = ["No Filter"] + Array(Plot.get_filter(@plot.class_var('filter_name')).map {|dd| dd.send(dd.attributes.to_a[0][0])}) unless !@plot.class_var('find_filter?')

    @x_default, @y_default, @filter_default, @feature_default = @plot.default_selections()

    @start_year = Plot.first_year
    @end_year   = Plot.last_year

  end



  #*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*  plotter  *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*#
  #                                                                                                                   #
  # Purpose:                                                                                                          #
  #     The PLOTTER method is responsible for taking the user's selections from the form built in  index.html.erb and #
  #     fetching data from the database based on that criteria. This simple task is more complicated than it seems.   #
  #     There is logic in place to handle the user selecting/neglecting X-Axis range inputs.                          #
  #     More important is the handling of the FILTER option. If the database does not need to be 'filtered', or there #
  #     is just one filter applied, there only needs to be one query of the database. All data then is stored in the  #
  #     @plot variable.                                                                                               #
  #                                                                                                                   #
  #     If there are multiple filters, this controller dynamically performs additional queries, and stores each       #
  #     dataset in its own instance variable, named after the filter string itself. This means the filter selection   #
  #     MUST be a string by the time it arrives here for querying.                                                    #
  #                                                                                                                   #
  #     Finally, it sets some instance variables that control extra plot features such as adding interactive          #
  #     checkboxes and linear regressions to the plot.                                                                #
  #                                                                                                                   #
  # NOTE:                                                                                                             #
  #     The @tags variable holds ALL variable names that are to be plotted. The rest of the app assumes that the order#
  #     of these variable names starts with the 'X' variable, and progresses through each 'Y' variable. In other words#
  #     @tags = [x_var, y1_var, y2_var, y3_var ...]                                                                   #
  #     So far, stacking scope statements so that the 'X' axis variable is added first ensures that this ordering     #
  #     works out. In the future, a rework of certain Plot methods to work off of:  params[:x_var] and                #
  #     params[:y_var] separately, instead of just iterating over   @tags  elements would be more robust              #
  #                                                                                                                   #
  #*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*#

  def plotter

    # If there is no :filter applied to the data, set this param to "No Filter"
    #   The   params[:filter]   will be used throughout the RoR plotting app, so if there
    #   is no need for a filter, setting   params[:filter] = "No Filter"   will allow the
    #   app to function appropriately.

    if !params[:filter]
      params[:filter] = "No Filter"
    end

    #   Check if the user has applied the param[:filter] to the plotting data.
    if params[:filter].exclude? "No Filter"

      # Convert to array if params[:filter] is a string. The rest of the app expects it as an array
      #   This situation arises when the :filter select_tag does NOT include a ":multiple => true",
      #   which turns the :filter param into a string, instead of an array of strings.
      if params[:filter].class == String
        params[:filter] = [params[:filter]]
      end

      # If only one filter, only one query needs to be executed. The results of that query can be placed
      #   directly into the    @plot    variable.
      if params[:filter].length == 1
        if !Plot.first.date_invalid(params[:date_start]) && !Plot.first.date_invalid(params[:date_end])
          @plot = Plot.between_dates((Plot.first.convert_date(params[:date_start])).to_s, (Plot.first.convert_date(params[:date_end])).to_s).
              select_var(params[:x_var]).select_var(params[:y_var]).select_filter(params[:filter].first)
        elsif !params[:x_start].blank? && !params[:x_end].blank? # If the user has input both a START and END value
          @plot = Plot.between_x(params[:x_start], params[:x_end]).select_var(params[:x_var]).select_var(params[:y_var]).select_filter(params[:filter].first)
        else
          @plot = Plot.select_var(params[:x_var]).select_var(params[:y_var]).select_filter(params[:filter].first)
        end

        @tags = @plot.first.list_vars - Array(@plot.first.class_var('filter_name')) # Don't want to treat "Ticker" as its own plotting variable, since its a string


      else  # Indicates that MULTIPLE     params[:filters]     have been applied

        # Each    params[:filter]    member corresponds to a unique query of the database. Each query is evaluated into
        #   an instance variable, named after that corresponding :filter member. Later, this app will iterate over all
        #   members to plot its data.
        params[:filter].each do |p|
          if !Plot.first.date_invalid(params[:date_start]) && !Plot.first.date_invalid(params[:date_end])
            eval("@" + p.to_s + "= Plot.between_dates((Plot.first.convert_date(params[:date_start])).to_s, (Plot.first.convert_date(params[:date_end])).to_s).
                select_var(params[:x_var]).select_var(params[:y_var]).select_filter(p)"   )
          elsif !params[:x_start].blank? && !params[:x_end].blank? # If the user has input both a START and END value
            eval("@" + p.to_s + "= Plot.between_x(params[:x_start], params[:x_end]).select_var(params[:x_var]).select_var(params[:y_var]).select_filter(p)")
          else
            eval("@" + p.to_s + "= Plot.select_var(params[:x_var]).select_var(params[:y_var]).select_filter(p)")
          end
        end
      end



    else
      if !Plot.first.date_invalid(params[:date_start]) && !Plot.first.date_invalid(params[:date_end])
        @plot = Plot.between_dates((Plot.first.convert_date(params[:date_start])).to_s, (Plot.first.convert_date(params[:date_end])).to_s).
            select_var(params[:x_var]).select_var(params[:y_var])
      elsif !params[:x_start].blank? && !params[:x_end].blank? # If the user has input both a START and END value
        @plot = Plot.between_x(params[:x_start], params[:x_end]).select_var(params[:x_var]).select_var(params[:y_var])
      else
        @plot = Plot.select_var(params[:x_var]).select_var(params[:y_var])
      end
      @tags = @plot.first.list_vars
      params[:filter] = ["No Filter Applied"]
    end

    # Choose which layout to render based on the "feature" parameter.

    case params[:feature]
      when 'Linear Regression'
        @linear = true
        @checkboxes = false
      when 'Checkboxes'
        @checkboxes = true
        @linear = false
      when 'Both'
        @linear = true
        @checkboxes = true
      when 'None' # Default, has no feature. Just a blank plot with no extra interaction.
        @linear = false
        @checkboxes = false
    end

  end


end
