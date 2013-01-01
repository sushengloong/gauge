# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  trans_pie_chart = new Highcharts.Chart
    chart:
      renderTo: 'chart-container'
      plotBackgroundColor: null
      plotBorderWidth: null
      plotShadow: false
    title:
      text: 'Browser market shares at a specific website, 2010'
    tooltip:
      pointFormat: 'Hello{series.name}: <b>{point.percentage}%</b>'
      percentageDecimals: 1
    plotOptions:
      pie:
        allowPointSelect: true
        cursor: 'pointer'
        dataLabels:
          enabled: true
          color: '#000000'
          connectorColor: '#000000'
          formatter: ->
            '101<b>'+ this.point.name +'</b>: '+ this.percentage +' %'
      series:[
        type: 'pie'
        name: 'Browser share'
        data: [
          ['Firefox',   45.0],
          ['IE',       26.8],
          {
              name: 'Chrome',
              y: 12.8,
              sliced: true,
              selected: true
          },
          ['Safari',    8.5],
          ['Opera',     6.2],
          ['Others',   0.7]
        ]
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
