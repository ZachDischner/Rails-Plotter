class Plot < ActiveRecord::Base
  # all documentation assumes that an instantiation of Plot is represented by the >> @plot  instance variable.

  set_table_name "stock_test"
  set_primary_key :id



  # To work, the  /APP/ASSETS MUST BE THE SAME!!!! MUST MUST!!!!!

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

    def all_checkboxes_true(list)
      return (["true"]*(list.length-1)).to_s
    end

    def all_checkboxes_false(list)
      return (["false"]*(list.length-1)).to_s
    end


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
          height: 400,                                                               // Specifies the Height of the plot area
          width: 840,                                                                // Specifies the Width of the plot area
          hideOverlayOnMouseOut: false,                                              // Keeps the legend visible at all times
          showRoller: true,                                                          // Show a rolling Average box
          rollPeriod: 1,                                                             // Set default average for rolling average (0 means no average...)
          labelsDivWidth: 100,                                                       // Set the
          labelsDiv: document.getElementById('Legend_Div" + graphnum.to_s + "'),     // Specifies External Div to put Legend Labels in
          labelsSeparateLines: true,                                                 // Different lines per label for easier readability
          underlayCallback: drawLines,                                               // MUST enable this  to show linear regression
          xlabel: '<%=params[:x_var]%>',                                             // Label for the X axis
          ylabel: '<%=render :inline => params[:y_var].to_s %>',                     // Labels for the Y axis
          visibility" + graphnum + ": <%= render :inline => @plot.first.all_checkboxes_true(params[:y_var]) %>   //
        } "
      return options_string
    end

    def linear_reg_buttons(list,graphnum="")

      #button_str = '<div style="position: relative; left: 1000px; top: -250px;">' + "\n"
      button_str = ''
      for ii in 0..list.length-1
        button_str += '<input type=button style="color:RGBColor(g' + graphnum.to_s + '.getColors().[' + ii.to_s + ']).toHex;" value="Regression For --> ' + list[ii] + '"
                                    onClick="regression' + graphnum.to_s + '(' + (ii + 1).to_s + '), coeffs_' + (ii+1).to_s + '()" />' + "\n"
        button_str += '<br/><div style="padding:5px; border:2px solid black" id="Div_' + (ii+1).to_s + '">Coefficients are: </div><br/>' + "\n"
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
        print_Coeffs(series);

      }

      function clearLines' + graphnum.to_s + '()
      {
        for (var i = 0; i < coeffs.length; i++)
        {
          coeffs[i] = null;
        }
        g' + graphnum.to_s + '.updateOptions({});
        clear_Coeffs()

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

     function print_Coeffs(ii)
        {
          var reg = coeffs[ii];
          var reg_str = "Coefficients are : <br>"
          reg_str += "y =  [" + Math.round(reg[0]*1000)/1000 + "] x  + [" + Math.round(reg[1]*1000)/1000 + "] </br>"
          document.getElementById("Div_" + ii).innerHTML = reg_str;
        }

      function clear_Coeffs' + graphnum.to_s + '(ii)
        {
          for (var i = 1; i < coeffs.length; i++) document.getElementById("Div_" + i).innerHTML = "Coefficients are:";
        }

    '
    end

    def convert_date(obj)
      return Date.new(obj['(1i)'].to_i, obj['(2i)'].to_i, obj['(3i)'].to_i)
    end

    def date_blank(mydate)
      return ([mydate["(1i)"].to_s.blank?, mydate["(2i)"].to_s.blank?, mydate["(3i)"].to_s.blank?]).include?(true)
    end


  def reform(rownames,col)
    x= "{"
    rownames.each do |name|
      x+= "'" + name + "'=>"  + name + ".map {|g| [ "+ self.hash_var(col) +"]}"
      x+= "," unless name==rownames.last
    end
    x += '}'
    return x
  end

  def hash_var(var)
    if var.class == String
      return "g.send('" + var + "')"
    end
  end

  def foo(bar="")
    return "g = g +" + bar
  end








    #*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^ Scopes ^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^*^#
    #
    # Scopes to govern the selection of data to be plotted. There are TWO 'classes' of selection methodologies for
    # basic database operations. More complicated tables will neccesitate more complicated selection schemes. It is
    # recommended that complicated logic regarding data selection be figured out here. That way the user interfaces with
    # this program the exact same for any level of complication, and logic does not need to be changed throughout the
    # app. The two basic selectors are as follows:
    #
    #   1. Selections based on ROWS in the database.
    #       eg: " SELECT * FROM table_name WHERE name='some name' "
    scope :between_dates, lambda { |start_date, end_date| where("Date > ? AND Date < ?", "#{start_date}", "#{end_date}") }
    scope :after_date, lambda { |start_date| where("Date > ?", "%#{start_date}") }

    scope :select_ticker, lambda {|tickername| where("ticker in (?)","#{tickername}")}

    scope :after_x, lambda { |x1| where("x >= ?", "#{x1}") }
    scope :before_x, lambda { |x2| where("x <=?", "#{x2}") }
    scope :between_x, lambda { |x1, x2| where("x BETWEEN ? and ?", "#{x1}", "#{x2}") }

    #   2. Selections based on COLUMNS in the database.
    #       eg: " SELECT (name,birthday,address) FROM table_name"
    scope :select_var, lambda { |varname| select(varname) }

    # Together, these two scope classes can be layered to create actual database queries
    #       eg:       RoR>> Plot.after_x(4).select_var('z')
    #       becomes:  SQL>> SELECT (z) FROM Plot where(x>4);

    # (1.5) "Filter" selection. This is the optional scope, which depends heavily on your database schema and how you want to plot.
    #         -This will get a list of distinct values in the "filter" column, which can be used in the interaction webpage to obtain
    #           separate datasets.
    #         -Technically, this is still a ROW based selection. However, in its implementation, the "filter" param will be utilized to create
    #           completely different datasets, not provide selection criteria.
    #         -For a stock market database, the user would want to plot stats (in columns) for different stocks.
    #           The stock names are stored in a "tickers" column. So In order to get a list of all tickers so that the
    #           user can make their decision, you can populate a drop down with values gathered from tis scope.
    #             eg:     RoR>> @stocks = Plot.select_filter("ticker")
    #             yeilds: ['aapl','goog','arwr',...]
    #          That array can be populated into a dropdown that the user can use to plot stock data based on its ticker.
    scope :select_filter, lambda {|filter| select("DISTINCT #{filter}")}

    #=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*#
  end
