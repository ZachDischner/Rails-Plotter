class PlotsController < ApplicationController

  def plotter

    #   Check if the user has applied the param[:filter] to the plotting data
    if params[:filter] != nil or params[:filter] != [""]

      # Convert to array if params[:filter] is a string. The rest of the app expects it as an array
      #   This situation arises when the :filter selection helper does not include a ":multiple => true",
      #   which turns the :filter param into a string, instead of an array of strings.
      if params[:filter].class == String
        params[:filter] = [params[:filter]]
      end

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

      end

    # If no filter has been applied, just get a single dataset.  NOT WORKING
    else
      if !Plot.first.date_blank(params[:date_start]) && !Plot.first.date_blank(params[:date_end])
        @plot = Plot.between_dates((Plot.first.convert_date(params[:date_start])).to_s, (Plot.first.convert_date(params[:date_end])).to_s).
            select_var(params[:x_var]).select_var(params[:y_var])
      elsif !params[:x_start].blank? && !params[:x_end].blank? # If the user has input both a START and END value
        @plot = Plot.between_x(params[:x_start], params[:x_end]).select_var(params[:x_var]).select_var(params[:y_var])
      else
        @plot = Plot.select_var(params[:x_var]).select_var(params[:y_var])
      end
    end

    # Choose which layout to render based on the "feature" parameter.
    case params[:feature]
      when 'Linear Regression'
        @mytemplate = "layouts/plot_linear_template"
      when 'Checkboxes'
        @mytemplate = "layouts/plot_checkbox_template"
      when 'Both'
        @mytemplate = "layouts/plot_checkbox_linear_template"
      else # Default, in case someone forgets to check their feature.
        @mytemplate = "layouts/plot_checkbox_linear_template"
    end

  end


  def index
    # These tags are to be excluded from any interactions, as they are database utilities
    exclude_tags = ["id","created_at","updated_at","ticker"]

    # Get a single row of info from the database around which to build the user interface
    @plots=Plot.first

    # Get an array of the collected data as an array of strings. This will be used throughout plotting
    @tags = @plots.list_vars - exclude_tags

    # Get tickers
    @filters = Plot.select_filter("ticker")
  end

  def create
    
  end

end
