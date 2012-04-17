(function() {
  jQuery(function() {
    var endCustomDateRange, g2, plotData, startCustomDateRange, toggleLogScale, using_log_scale;
    g2 = null;
    using_log_scale = false;
    startCustomDateRange = function(input) {
      var dateMax, dateMin, results;
      dateMin = new Date(2010, 3 - 1, 26);
      dateMax = jQuery('#end_date').datepicker("getDate");
      if (dateMax === null) {
        dateMax = new Date();
      }
      return results = {
        minDate: dateMin,
        maxDate: dateMax
      };
    };
    endCustomDateRange = function(input) {
      var dateMax, dateMin, results;
      dateMin = jQuery('#start_date').datepicker("getDate");
      if (dateMin === null) {
        dateMin = new Date(2010, 3 - 1, 26);
      }
      dateMax = new Date();
      return results = {
        minDate: dateMin,
        maxDate: dateMax
      };
    };
    plotData = function() {
      var ajax_param, bd_or_l, dygraph_options, plot_title, submit_data, the_url;
      bd_or_l = jQuery("#band_diode_or_line option:selected").val();
      plot_title = bd_or_l.replace(/_/g, ' ');
      jQuery("#plot_title").html(plot_title);
      submit_data = jQuery("#particulars_form").serialize();
      the_url = 'cgi-bin/get_eve_l2_averages.cgi?' + submit_data;
      jQuery("#canvas").showLoading();
      dygraph_options = {
        width: 960,
        height: 400,
        xlabel: 'Time',
        ylabel: 'Average Irradiance (linear scale)',
        yAxisLabelWidth: 85,
        logscale: false
      };
      ajax_param = {
        url: the_url,
        success: function(data) {
          var canvas_div;
          jQuery("#canvas").hideLoading();
          canvas_div = document.getElementById("canvas");
          g2 = new Dygraph(canvas_div, data, dygraph_options);
        }
      };
      jQuery.ajax(ajax_param);
      jQuery('#scaling').attr({
        'class': "visible",
        'value': 'Log Scale   '
      });
      jQuery('#unzoom').attr({
        'class': "visible"
      });
      jQuery('#unzoom_a_little').attr({
        'class': "visible"
      });
      jQuery('#instructions').attr({
        'class': "visible"
      });
      jQuery('#get_data').attr({
        'class': "visible"
      });
    };
    toggleLogScale = function() {
      var y_label;
      if (using_log_scale) {
        y_label = 'Average Irradiance (linear scale)';
        jQuery('#scaling').attr({
          'value': 'Log Scale   '
        });
        using_log_scale = false;
      } else {
        y_label = 'Average Irradiance (log scale)';
        jQuery('#scaling').attr({
          'value': 'Linear Scale'
        });
        using_log_scale = true;
      }
      return g2.updateOptions({
        logscale: using_log_scale,
        ylabel: y_label
      });
    };
    jQuery('#start_date').datepicker({
      showOn: "focus",
      beforeShow: startCustomDateRange,
      dateFormat: "dd M yy",
      firstDay: 1,
      changeFirstDay: false
    });
    jQuery('#end_date').datepicker({
      showOn: "focus",
      beforeShow: endCustomDateRange,
      dateFormat: "dd M yy",
      firstDay: 1,
      changeFirstDay: false
    });
    jQuery("#plot_data").click(plotData);
    jQuery("#unzoom").click(function() {
      var newOptions;
      newOptions = {
        dateWindow: null,
        valueRange: null
      };
      return g2.updateOptions(newOptions);
    });
    jQuery("#unzoom_a_little").click(function() {
      var max_x, min_x, newOptions, span, ten_percent, x_range;
      x_range = g2.xAxisRange();
      span = x_range[1] - x_range[0];
      ten_percent = span * 0.1;
      min_x = x_range[0] - ten_percent;
      max_x = x_range[1] + ten_percent;
      newOptions = {
        dateWindow: [min_x, max_x]
      };
      return g2.updateOptions(newOptions);
    });
    jQuery("#scaling").click(function() {
      return toggleLogScale(true);
    });
    jQuery("#get_data").click(function() {
      var submit_data, url;
      submit_data = jQuery("#particulars_form").serialize();
      url = 'cgi-bin/download_eve_l2_averages.cgi?' + submit_data;
      return window.open(url);
    });
  });
}).call(this);
