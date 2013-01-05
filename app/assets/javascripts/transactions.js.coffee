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
      text: 'Transaction Trend'
    yAxis:
      title:
        text: ''
    xAxis:
      categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May']
    tooltip:
      formatter: ->
        '' + this.series.name + ': ' + this.y + ''
    plotOptions:
      column:
        stacking: 'normal'
    series: [
      name: 'Income'
      type: 'column'
      data: [3000, 3500, 3200, 4800, 3000]
      stack: 0
    ,
      name: 'Expenses'
      type: 'column'
      data: [-1000, -4000, -1300, -1800, -1200]
      stack: 0
    ,
      name: 'Net Income'
      type: 'line'
      data: [2000, -500, 1900, 3000, 1800]
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
    aoColumns: [null, null, null, {sType: "currency"}]
    bPaginate: false
    aaSorting: []
    oLanguage:
      sEmptyTable: "No transaction available"

  new FixedHeader oTable,
    offsetTop: 40

  $("input#filter_text_field").keyup ->
    oTable.fnFilter ''
    oTable.fnFilter $(this).val()

  $("input.datepicker").datepicker
    dateFormat: "dd M yy"

  $(window).scroll ->
    console.log $(this).scrollTop()+40
    console.log $("#transactions_datatable").offset().top
    console.log("-----")
    if ($(this).scrollTop()+40) >= $("#transactions_datatable").offset().top
      $("#fixed-footer").show()
    else
      $("#fixed-footer").hide()
