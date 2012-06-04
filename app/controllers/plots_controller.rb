class PlotsController < ApplicationController

  #*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^ Plot Controller ^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^#
  #
  # This controller handles the fetching and organization of data from the database, and then routing that data
  #   into the correct VIEW pages.
  # As of now, there are two pages associated with the plotting app.
  #   1. Index.html.erb. This page  Creates a table full of options that allows the user to select criteria used for
  #      database querying and data collection.
  #   2. plotter.html.erb. This page dynamically takes the users selection data criteria, fetches the data for plotting,
  #      and
  #
  #=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*#

  def index
    # Used in the "index" page to activate helper popups that help in development
    params[:debug] = true

    # These tags are to be excluded from any interactions, as they are database utilities, strings, or
    # otherwise unplottable data.
    exclude_tags = ["created_at","updated_at","ticker"]

    # Get a single row of info from the database around which to build the user interface
    @plot=Plot.first

    # Get an array of the collected data as an array of strings. This will be used throughout plotting
    @tags = @plot.list_vars - exclude_tags

    # Get Filters, add a "No Filter" option for fast implementation of databases without need for filtering.
    # Ideally, this is all taken out later for such applications.
    @filters = ["No Filter"] + Plot.select_filter("ticker").map {|dd| dd.ticker} unless !@plot.filter_table

    @x_default, @y_default, @filter_default, @feature_default = @plot.default_selections()

  end


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
        if !Plot.first.date_blank(params[:date_start]) && !Plot.first.date_blank(params[:date_end])
          @plot = Plot.between_dates((Plot.first.convert_date(params[:date_start])).to_s, (Plot.first.convert_date(params[:date_end])).to_s).
              select_var(params[:x_var]).select_var(params[:y_var]).select_ticker(params[:filter].first)
        elsif !params[:x_start].blank? && !params[:x_end].blank? # If the user has input both a START and END value
          @plot = Plot.between_x(params[:x_start], params[:x_end]).select_var(params[:x_var]).select_var(params[:y_var]).select_ticker(params[:filter].first)
        else
          @plot = Plot.select_var(params[:x_var]).select_var(params[:y_var]).select_ticker(params[:filter].first)
        end

        @tags = @plot.first.list_vars - ["Ticker"] # Don't want to treat "Ticker" as its own plotting variable, since its a string


      else  # Indicates that MULTIPLE     params[:filters]     have been applied

        # Each    params[:filter]    member corresponds to a unique query of the database. Each query is evaluated into
        #   an instance variable, named after that corresponding :filter member. Later, this app will iterate over all
        #   members to plot its data.
        params[:filter].each do |p|
          if !Plot.first.date_blank(params[:date_start]) && !Plot.first.date_blank(params[:date_end])
            eval("@" + p.to_s + "= Plot.between_dates((Plot.first.convert_date(params[:date_start])).to_s, (Plot.first.convert_date(params[:date_end])).to_s).
                select_var(params[:x_var]).select_var(params[:y_var]).select_ticker(p)"   )
          elsif !params[:x_start].blank? && !params[:x_end].blank? # If the user has input both a START and END value
            eval("@" + p.to_s + "= Plot.between_x(params[:x_start], params[:x_end]).select_var(params[:x_var]).select_var(params[:y_var]).select_ticker(p)")
          else
            eval("@" + p.to_s + "= Plot.select_var(params[:x_var]).select_var(params[:y_var]).select_ticker(p)")
          end
        end
      end



    else
      if !Plot.first.date_blank(params[:date_start]) && !Plot.first.date_blank(params[:date_end])
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
      else # Default, has no feature. Just a blank plot with no extra interaction.
        @linear = false
        @checkboxes = false
    end

  end


end
