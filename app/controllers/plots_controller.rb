class PlotsController < ApplicationController

  def plotter
    if params[:tickers].length == 1
      if !Plot.first.date_blank(params[:date_start]) && !Plot.first.date_blank(params[:date_end])
        @plot = Plot.between_dates((Plot.first.convert_date(params[:date_start])).to_s, (Plot.first.convert_date(params[:date_end])).to_s).
            select_var(params[:x_var]).select_var(params[:y_var]).select_ticker(params[:tickers].first)
      elsif !params[:x_start].blank? && !params[:x_end].blank? # If the user has input both a START and END value
        @plot = Plot.between_x(params[:x_start], params[:x_end]).select_var(params[:x_var]).select_var(params[:y_var]).select_ticker(params[:tickers].first)
      else
        @plot = Plot.select_var(params[:x_var]).select_var(params[:y_var]).select_ticker(params[:tickers].first)
      end

      @tags = @plot.first.list_vars - ["Ticker"] # Don't want to treat "Ticker" as its own plotting variable, since its a string


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
  end



  def index
    # These tags are to be excluded from any interactions, as they are database utilities
    exclude_tags = ["id","created_at","updated_at","ticker"]

    # Get a single row of info from the database around which to build the user interface
    @plots=Plot.first

    # Get an array of the collected data as an array of strings. This will be used throughout plotting
    @tags = @plots.list_vars - exclude_tags

    # Get tickers
    @tickers = Plot.select("DISTINCT ticker")
  end

  def create
    
  end

end
