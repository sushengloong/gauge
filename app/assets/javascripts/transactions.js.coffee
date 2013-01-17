# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->

  trend_chart = breakdown_chart = null

  $('a[data-toggle="tab"]').on 'shown', (e)->
    # lazy-loading other charts
    if $(this).attr('href') == '#breakdown-chart-container-pane' && (typeof(breakdown_chart) == 'undefined' || breakdown_chart == null)
      breakdown_chart = new Highcharts.Chart
        chart:
          renderTo: 'breakdown-chart-container'
          plotBackgroundColor: null
          plotBorderWidth: null
          plotShadow: false
        title:
          text: 'Transaction Breakdown'
        tooltip:
          pointFormat: '{series.name}: <b>${point.y} ({point.percentage}%)</b>'
          percentageDecimals: 2
        plotOptions:
          pie:
            allowPointSelect: true
            cursor: 'pointer'
            dataLabels:
              enabled: true
              color: '#000000'
              connectorColor: '#000000'
              formatter: ->
                '<b>' + this.point.name + '</b>: $' + Highcharts.numberFormat(this.point.y, 2) \
                  + ' (' + Highcharts.numberFormat(this.point.percentage, 2) + ' %)'
        series:[
          type: 'pie'
          name: 'Transaction Breakdown'
          data: transactions_chart_data
        ]
        colors: ['#AA4643', '#50B432']

  trend_chart = new Highcharts.Chart
    chart:
      renderTo: 'trend-chart-container'
    title:
      text: 'Transaction Trends'
    yAxis:
      title:
        text: ''
    xAxis:
      categories: past_transaction_trends["months"]
    tooltip:
      formatter: ->
        '' + this.series.name + ': ' + this.y + ''
    plotOptions:
      column:
        stacking: 'normal'
    series: [
      name: 'Income'
      type: 'column'
      data: past_transaction_trends["income"]
      stack: 0
    ,
      name: 'Expenses'
      type: 'column'
      data: past_transaction_trends["expenses"]
      stack: 0
    ,
      name: 'Net Income'
      type: 'line'
      data: past_transaction_trends["net_income"]
    ]

  $.extend $.fn.dataTableExt.oSort,
    "currency-pre": (a) ->
      a = (if (a is "-") then 0 else a.replace(/[^\d\.]/g, ""))
      parseFloat a
    "currency-asc": (a, b) ->
      a - b
    "currency-desc": (a, b) ->
      b - a

    "formatted-num-pre": (a) ->
      a = (if (a is "-") then 0 else a.replace(/[^\d\.]/g, ""))
      parseFloat( a )
    "formatted-num-asc": (a,b) ->
      a - b
    "formatted-num-desc": (a,b) ->
      b - a

  oTable = $('table#transactions_datatable').dataTable
    sDom: '<"H"lr>t<"F"ip>'
    aoColumns: [
      bSearchable: false
      bVisible: false
    , null, null, null
      sType: "currency"
    ,
      bSearchable: false
      bVisible: false
    ]
    bPaginate: false
    aaSorting: []
    oLanguage:
      sEmptyTable: "No transaction available"

  new FixedHeader oTable,
    offsetTop: 40

  # create detail row code
  fn_format_details = (table, tr)->
    aData = table.fnGetData(tr)
    output = ''
    $.ajax
      type: 'GET'
      async: false
      url: aData[5]
    .done (data, textStatus, jqXHR)->
      output += data
    output

  # keep track of opened row. always close an opened row before opening another row.
  cur_open_row = null

  # bind each row click event to show detail row
  $('table#transactions_datatable tbody tr').on 'click', ->
    if oTable.fnIsOpen this
      oTable.fnClose this
      cur_open_row = null
    else
      if cur_open_row
        oTable.fnClose cur_open_row
      oTable.fnOpen(this, fn_format_details(oTable, this), 'edit_transaction_details')
      cur_open_row = this

  $("input#filter_text_field").keyup ->
    oTable.fnFilter ''
    oTable.fnFilter $(this).val()

  $("input.datepicker").datepicker
    dateFormat: "dd M yy"

  # Scrolling pass datatable header displays sticky footer
  $(window).scroll ->
    if ($(this).scrollTop()+40) >= $("#transactions_datatable").offset().top
      $("#fixed-footer").slideDown("fast")
    else
      $("#fixed-footer").slideUp("fast")

  $('.scrollup').click (e)->
    e.preventDefault
    $("body").animate
      scrollTop: 0
    , 600

  # Poll server for sync ibanking job status
  poll_sync_job_status = (job_id)->
    $.ajax
      type: 'POST'
      url: $("#sync_ibanking_form input#query_url").val(),
    .done (data, textStatus, jqXHR)->
      if data.status == 'Done'
        window.location = $("#sync_ibanking_form input#redirect_url").val() + "?sync_num=" + data.num
      else if data.status == 'Error'
        msg_div = $("#sync_ibanking_form_msg")
        msg_div.text "Error: " + data.message
        msg_div.removeClass()
        msg_div.addClass 'text-error'
        $.unblockUI()
      else
        setTimeout poll_sync_job_status, 5000
    .fail (jqXHR, textStatus, errorThrown)->
      alert(errorThrown)
      $.unblockUI()

  # AJAX callback for sync ibanking
  $('form#sync_ibanking_form').on 'ajax:success', (evt, xhr, status, error)->
    msg_div = $(this).find("#sync_ibanking_form_msg")
    msg_div.text "syncing...please wait for a short while..."
    msg_div.addClass 'text-info'
    $.blockUI
      message: 'syncing up your ibanking...please wait for a short while...'
      baseZ: 9999
    setTimeout(poll_sync_job_status, 30000)
  .on 'ajax:error', (evt, xhr, status, error)->
    resp = $.parseJSON(xhr.responseText)
    msg_div = $(this).find("#sync_ibanking_form_msg:first")
    msg_div.text resp['message'] || "unknown error!"
    msg_div.addClass 'text-error'

  # datepickers
  $('.datepicker').datepicker()
