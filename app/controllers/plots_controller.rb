class PlotsController < ApplicationController
  def all
    @plot = Plot.select_var(['DataDate','x','y1','y2'])
  end

  def plotter
    if !Plot.first.date_blank(params[:date_start])  && !Plot.first.date_blank(params[:date_end])
      @plot = Plot.between_dates((Plot.first.convert_date(params[:date_start])).to_s, (Plot.first.convert_date(params[:date_end])).to_s).
                                    select_var(params[:x_var]).select_var(params[:y_var])
    elsif !params[:x_start].blank?  &&  !params[:x_end].blank?  # If the user has input both a START and END value
      @plot = Plot.between_x(params[:x_start],params[:x_end]).select_var(params[:x_var]).select_var(params[:y_var])
    else
     # @plot = Plot.select_var(params[:x_var]).select_var(params[:y_var])
      @plot = Plot.select_var(params[:x_var]).select_ticker("aapl").select_var(params[:y_var])
    end
    @tags = @plot.first.list_vars

    case params[:feature]
      when 'Linear Regression'
        @mytemplate = "layouts/plot_linear_template"
      when 'Checkboxes'
        @mytemplate = "layouts/plot_checkbox_template"
      when 'Both'
        @mytemplate = "layouts/plot_checkbox_linear_template"
      else    # Default, in case someone forgets to check their feature.
        @mytemplate = "layouts/plot_checkbox_linear_template"
    end

  end



  def index
    # These tags are to be excluded from any interactions, as they are database utilities
    exclude_tags = ["id","created_at","updated_at"]

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
