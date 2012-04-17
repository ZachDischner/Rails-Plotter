jQuery ->

    g2 = null
    using_log_scale = false

    startCustomDateRange = (input) ->
      dateMin = new Date(2010, 3 - 1, 26)
      dateMax = jQuery('#end_date').datepicker("getDate")
      if dateMax is null
        dateMax = new Date()
      results =
        minDate: dateMin
        maxDate: dateMax
  
    endCustomDateRange = (input) ->
      dateMin = jQuery('#start_date').datepicker("getDate")
      if dateMin is null
        dateMin = new Date(2010, 3 - 1, 26)
      dateMax = new Date()
      results =
        minDate: dateMin
        maxDate: dateMax

    plotData = ->
      bd_or_l = jQuery("#band_diode_or_line option:selected").val()
      plot_title = bd_or_l.replace(/_/g, ' ')
      jQuery("#plot_title").html(plot_title)
      submit_data = jQuery("#particulars_form").serialize()
      the_url = 'cgi-bin/plot_averages/get_eve_l2_averages.cgi?' + submit_data
      jQuery("#canvas").showLoading()
      dygraph_options =
        width : 960
        height : 400
        xlabel : 'Time'
        ylabel : 'Average Irradiance (linear scale)'
        yAxisLabelWidth : 85
        logscale : false
      ajax_param =
        url: the_url
        success: (data) ->
          jQuery("#canvas").hideLoading()
          canvas_div = document.getElementById("canvas")
          g2 = new Dygraph(canvas_div, data, dygraph_options)
          return
      jQuery.ajax(ajax_param)
      jQuery('#scaling').attr({ 'class': "visible", 'value': 'Log Scale   '})
      jQuery('#unzoom').attr({ 'class': "visible" })
      jQuery('#unzoom_a_little').attr({ 'class': "visible" })
      jQuery('#instructions').attr({ 'class': "visible" })
      jQuery('#get_data').attr({ 'class': "visible" })
      return

    toggleLogScale = ->
      if using_log_scale
        y_label = 'Average Irradiance (linear scale)'
        jQuery('#scaling').attr({ 'value': 'Log Scale   ' })
        using_log_scale = false
      else
        y_label = 'Average Irradiance (log scale)'
        jQuery('#scaling').attr({ 'value': 'Linear Scale' })
        using_log_scale =  true

      g2.updateOptions({ logscale: using_log_scale, ylabel: y_label })

    jQuery('#start_date').datepicker({
      showOn: "focus",
      beforeShow: startCustomDateRange,
      dateFormat: "dd M yy",
      firstDay: 1,
      changeFirstDay: false})

    jQuery('#end_date').datepicker({
      showOn: "focus",
      beforeShow: endCustomDateRange,
      dateFormat: "dd M yy",
      firstDay: 1,
      changeFirstDay: false})

    jQuery("#plot_data").click(plotData)

    jQuery("#unzoom").click ->
      newOptions =
        dateWindow: null
        valueRange:null
      g2.updateOptions(newOptions)

    jQuery("#unzoom_a_little").click ->
      x_range = g2.xAxisRange()
      span = x_range[1] - x_range[0]
      ten_percent = span * 0.1
      min_x = x_range[0] - ten_percent
      max_x = x_range[1] + ten_percent
      newOptions = 
        dateWindow: [min_x, max_x]
      g2.updateOptions(newOptions)

    jQuery("#scaling").click ->
      toggleLogScale(true)

    jQuery("#get_data").click ->
      submit_data = jQuery("#particulars_form").serialize()
      url = 'cgi-bin/plot_averages/download_eve_l2_averages.cgi?' + submit_data
      window.open(url)

    #alert('javascript syntax is ok')

    return
