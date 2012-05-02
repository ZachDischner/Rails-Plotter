#*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^ Plot Class ^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^#
#
#  Written by:
#             Zach Dischner for LASP scientific uses
#  Updated:
#             May 1, 2012
#  Contact:
#             zach.dischner@lasp.colorado.edu
#             zach.dischner@gmail.com
# Purpose:
#  The Plot Class has two main tasks:
#      1. Define methods to query your database to select appropriate data
#      2. Take that data and dynamically generate HTML/dygraphs logic.
#
#  Plot HTML templates can be found in the   >>/app/views/layouts/plot_*
#  These templates define the proper methodology to use Plot methods to generate relevant dygraphs HTML.
#
#  The general procedure for generating a single dygraphs plot in an HTML page is as follows:
#          1. Appropriate a div for the plot ("graphdiv#")
#          2. Create a new dygraphs element ("g#" )
#          3. Generate the header for the graph. This allows a legend to correlate values with variable names
#          4. Generate the graph content, or the body of the graph. This parses database values into a string
#             recognizable by dygraphs functions.
#          5. Generate dygraphs option specifications for each graph.
#          6. Generate linear regression logic and HTML if wanted.
#          7. Generate checkbox logic and HTML elements if wanted.
#
#  Each of these tasks is made to be dynamic and iterative, so as to provide means to plot any generic dataset.
#  Also note that each of these tasks is closely related with the other. Changing one will have a high probability
#     changing the others. BEWARE!!!
#
#  On that note, this IS designed to be extremely generic. Changing functionality to fit your specific application will
#     likely make more sense eventually.
#
#  Case-In-Point: I'm not a rails master. In fact, this is my first rails app, my first experience with HTML, web design,
#     ruby, and my first attempt at Object-Oriented programming in general. As such, I'm probably pretty bad at it, and
#     the design of this application seems to violate many hard-and-fast practices of OO programming.
#  All of the methods below act more like functions. In fact, nothing about this 'class' resembles an object. The reason
#     for this is that this application is meant to work generically on any DATASET. This brings about problems:
#     1. Since the app is not designed around any specific database model, its logic can't be aware of the database
#        schema or elements. Methods and operations must perform their tasks without being consious of what they are
#        operating on.
#     2. By working with just raw random data, returns from the database are really more of data STRUCTURES, rather
#        than specific data OBJECTS. It makes no sense to try and think about these returns as objects. Without knowing
#        anything about the data, its useless to try and form it all into objects. Its like calling it a "Thing", and
#        saying that "Thing" has other "things", and can do "stuff".
#     3. Even if we knew what kind of data we are fetching, we really aren't fetching objects. We're fetching a big hunk
#        of (mainly) numeric data.
#     Both of these reasons point towards treating data as structures, and performing procedural operations on that data.
#        So this app is designed around that notion. But hey, I'm a noob. I could be totally wrong and its just my desire
#        to default back to a MATLAB mindset!
#     Either way, I designed all of these methods to work on arbitrary datasets. I did it this way for flexibility,
#        modularity, and ease of comprehension. They could easily be modified to have more Object-like behavior,
#        so feel free to do so.
#
#
#
#=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*==*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*#

class Plot < ActiveRecord::Base




  # Change table info and scopes below to match your database.
  # MYSQL development database
  establish_connection :development
  set_table_name "stock_test"
  set_primary_key :id
  @@find_filter = true


  #SQLITE test development environment
  #establish_connection(:adapter => "sqlite3", :database => "db/sqlite_test.sqlite3", :pool => 5 )
  #establish_connection :sqlite_test
  #set_table_name "plots"
  #@@find_filter = false

  def filter_table
    return  @@find_filter
  end



  #*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^ Scopes ^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^#
  #
  # Scopes to govern the selection of data to be plotted. There are TWO 'classes' of selection methodologies for
  #   basic database operations. More complicated tables will neccesitate more complicated selection schemes. It is
  #   recommended that complicated logic regarding data selection be figured out here. That way the user interfaces with
  #   this program the exact same for any level of complication, and logic does not need to be changed throughout the
  #   app. The two basic selectors are as follows:
  #
  #   1. Selections based on ROWS in the database.
  #       eg: " SELECT * FROM table_name WHERE name='some name' "
  #
  #     1.1 DATE SCOPES: Change the "Date" in the following sql parser argument. "Date" should be changed to the name of
  #                      the column in your database that corresponds to a DATETIME field.
  scope :between_dates, lambda { |start_date, end_date| where("Date > ? AND Date < ?", "#{start_date}", "#{end_date}") }
  scope :after_date, lambda { |start_date| where("Date > ?", "%#{start_date}") }

  #     1.2 STRING SCOPES: Change the "ticker" string in the following sql parser argument. This is for selection of rows
  #                        containing certain strings in your database, based on a column full of strings.
  #                     EG. if you have a column called "Names" in your database, you want to change "ticker" --> "Names"
  #                        and pass a single name ("Joe", "Sally") to the selector as an argument.
  scope :select_ticker, lambda { |tickername| where("ticker in (?)", "#{tickername}") }


  #     1.3 NUMERIC SCOPES: Change "x" to whichever numeric column you want to filter by.
  #                     EG. "x" can be 'laps','orbits', or just some index you would want to truncate your dataset by.
  #                         If you have y(x), but don't want to plot y for ALL values of x, use these scopes to truncate
  #                         your dataset.
  scope :after_x, lambda { |x1| where("x >= ?", "#{x1}") }
  scope :before_x, lambda { |x2| where("x <=?", "#{x2}") }
  scope :between_x, lambda { |x1, x2| where("x BETWEEN ? and ?", "#{x1}", "#{x2}") }

  # (1.5) "Filter" selection. This is the optional scope, which depends heavily on your database schema and how you want to plot.
  #         -This will get a list of distinct values in the "filter" column, which can be used in the interaction webpage to obtain
  #           separate datasets.
  #         -Technically, this is still a ROW based selection. However, in its implementation, the "filter" param will be utilized to create
  #           completely different datasets, not provide selection criteria.
  #         -For a stock market database, the user would want to plot stats (in columns) for different stocks.
  #           The stock names are stored in a "tickers" column. So In order to get a list of all tickers so that the
  #           user can make their selection, you can populate a drop down with values gathered from this scope.
  #             eg:     RoR>> @stocks = Plot.select_filter("ticker")
  #             yeilds: ['aapl','goog','arwr',...]
  #          That array can be populated into a drop-down that the user can use to plot stock data based on its ticker.
  scope :select_filter, lambda {|filter| select("DISTINCT #{filter}")}

  #   2. Selections based on COLUMNS in the database.
  #       eg: " SELECT (name,birthday,address) FROM table_name"
  scope :select_var, lambda { |varname| select(varname) }

  # Together, these two scope classes can be layered to create actual database queries
  #       eg:       RoR>> Plot.after_x(4).select_var('z')
  #       becomes:  SQL>> SELECT ('z') FROM Plot where(x>4);
  #
  #=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*#



 #>>>>>>>>>>>> Everything Below this line shouldn't be changed unless you REALLY want to  <<<<<<<<<<<<<<#




  # To work, the  /APP/ASSETS MUST have the "dygraph-combined.js"

    #*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^ list_vars ^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*#
    # Purpose:                                                                  #
    #     Return an array of attribute names as strings.                        #
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

    #=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#


    #*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^ put_checkboxes ^*^*^*^*^*^*^*^*^*^*^*^*^*^*^#
    # Purpose:                                                                  #
    #     Dynamically generate HTML for checkboxes. These will provide the      #
    #     user with a quick way to toggle multiple plot sets on the current     #
    #     chart.                                                                #
    #     *Note that this is HTML, that is tied to DYGRAPHS functionality.      #
    #     Modify appropriately                                                  #
    # Calling:                                                                  #
    #         >> @plot.first.put_checkboxes(y_vars)                             #
    #     This dynamically makes HTML that activates a check box for each of    #
    #     the y_var strings.                                                    #
    # Example:                                                                  #
    #     If the Y variables of a plot are contained within an array as:        #
    #         >>params[:y_var] = ['y1','y2']                                    #
    #     Then inside a view:  #                                                #
    #         <%=render :inline => @plot.first.put_checkboxes(params[:y_var])%> #
    #     *Note that this function returns a formated string. So in order to    #
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

    #=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*#


    #*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^ all_checkboxes_true  *^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*#
    # Purpose:                                                                              #
    #     Generate list of true/false strings. Not complicated, just replicates             #
    #     'true' or 'false' for placement in dygraphs options                               #
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

    def all_checkboxes_true(list)
      return (["true"]*(list.length-1)).to_s
    end
    #=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#


    #*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^ all_checkboxes_false  *^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^#
    #  Same as >>all_checkbox_true() except that using this function turns all plots
    #  off initially
    #<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>---<*>#
    def all_checkboxes_false(list)
      return (["false"]*(list.length-1)).to_s
    end
    #=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=#



    def dygraph_head(tags)
      labelstring = ",'"
      for ii in 0..(tags.length-1)
        labelstring += tags[ii].to_s
        labelstring += ',' unless (ii==(tags.length-1))
      end
      labelstring += '\n' +"'+"

      return labelstring
    end

    # Meant to work on ARRAYS of Plot OBJECTS, may want to redo to work for a hash
    def dygraph_body(tags, values)
      valuestring = ''
      values.each do |value|
        ; # for each row in the @plot selection
        valuestring += "'"
        for ii in 0..(tags.length-1) # for each tag (column) in that row
          valuestring += (value.send(tags[ii].to_s)).to_s
          valuestring += ',' unless (ii==(tags.length-1))
        end # End format is <   'x_value,y_value,y2_value,y3_value\n' +  >
        valuestring += '\n' + "'"
        valuestring += "   +" unless value==values.last
      end
      return valuestring
    end

    def dygraph_options(graphnum="")
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
          underlayCallback: drawLines" + graphnum.to_s + ",                          // MUST enable this  to show linear regression
          xlabel: '<%=params[:x_var]%>',                                             // Label for the X axis
          ylabel: '<%=render :inline => params[:y_var].to_s %>',                     // Labels for the Y axis
          visibility: <%= render :inline => @plot.first.all_checkboxes_true(params[:y_var]) %>   //
        } "
      return options_string
    end

    def linear_reg_buttons(list,graphnum="")

      #button_str = '<div style="position: relative; left: 1000px; top: -250px;">' + "\n"
      button_str = ''
      for ii in 0..list.length-1
        button_str += '<input type=button style="color:RGBColor(g' + graphnum.to_s + '.getColors().[' + ii.to_s + ']).toHex;" value="Regression For --> ' + list[ii] + '"
                                    onClick="regression' + graphnum.to_s + '(' + (ii + 1).to_s + '), coeffs_' + (ii+1).to_s + '()" />' + "\n"
        button_str += '<br/><div style="padding:5px; border:2px solid black" id="Div_' + graphnum.to_s  + (ii+1).to_s + '">Coefficients are: </div><br/>' + "\n"
      end
      button_str += '<input type=button value="Clear Lines" onClick="clearLines' + graphnum.to_s + '()" />' + "\n"
      #button_str += '</div>'   + "\n"
      return button_str
    end


    def linear_reg(graphnum = "")
      return '// coefficients of regression for each series.
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


      // Here is my function to format and return Linear Regression Ceofficients
      //    It places a formatted string of coefficients in the appropriately named
      //    <div>. Dynamic naming of each line series space as <div_0> , <div_1>
      //    etc is required for this to work. That way, each time a regression is
      //    calculated for a series (0,1,2...), the matching coefficient calculation
      //    will be put in the like-named divs. A similar function is also below to
      //    clear the appropriate coefficient strings when the linear regressions
      //    themselves are cleared.

     function print_Coeffs' + graphnum.to_s + '(ii)
        {
          var reg = coeffs[ii];
          var reg_str = "Coefficients are : <br>"
          reg_str += "y =  [" + Math.round(reg[0]*1000)/1000 + "] x  + [" + Math.round(reg[1]*1000)/1000 + "] </br>"
          document.getElementById("Div_' + graphnum.to_s + '" + ii).innerHTML = reg_str;
        }

      function clear_Coeffs' + graphnum.to_s + '(ii)
        {
          for (var i = 1; i < coeffs.length; i++) document.getElementById("Div_' + graphnum.to_s + '" + i).innerHTML = "Coefficients are:";
        }

    '
    end

    def convert_date(obj)
      return Date.new(obj['(1i)'].to_i, obj['(2i)'].to_i, obj['(3i)'].to_i)
    end

    def date_blank(mydate)
      return ([mydate["(1i)"].to_s.blank?, mydate["(2i)"].to_s.blank?, mydate["(3i)"].to_s.blank?]).include?(true)
    end


  end
