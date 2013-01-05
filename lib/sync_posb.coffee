casper = require('casper').create
  verbose: true
  logLevel: 'debug'

casper.start 'https://internet-banking.dbs.com.sg/posb', ->
  this.log 'URL: ' + this.getCurrentUrl()

casper.then ->
  this.evaluate ->
    document.querySelector('#UID').value = '%UID%'
    document.querySelector('#PIN').value = '%PIN%'
    document.querySelector('input[value="Submit"]').click()
  
casper.then ->
  this.log 'Last login: ' + this.evaluate ->
    window.frames[0].frames[3].document.getElementsByClassName('MFBodyTextBold')[0].innerHTML

casper.run()
