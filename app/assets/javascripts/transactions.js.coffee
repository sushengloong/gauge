# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
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
    aoColumns: [null, null, null, {sType: "currency"}]
    bPaginate: false
    aaSorting: []
    oLanguage:
      sEmptyTable: "No transaction available"

  new FixedHeader oTable,
    offsetTop: 40
