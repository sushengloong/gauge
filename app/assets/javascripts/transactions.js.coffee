# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  oTable = $('table#transactions_datatable').dataTable
    bPaginate: false
    aaSorting: []
    oLanguage:
      "sEmptyTable": "No transaction available"

  new FixedHeader oTable,
    offsetTop: 40
