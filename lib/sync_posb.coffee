casper = require('casper').create
  #verbose: true
  #logLevel: 'debug'
  clientScripts: ['lib/assets/javascripts/jquery.min.js']

casper.on 'remote.message', (msg)->
    this.echo('remote message caught: ' + msg)

casper.start 'https://internet-banking.dbs.com.sg/posb', ->
  #this.log 'URL: ' + this.getCurrentUrl()

casper.then ->
  uid = this.cli.get(0)
  pin = this.cli.get(1)
  this.evaluate (uid, pin)->
    document.querySelector('#UID').value = uid
    document.querySelector('#PIN').value = pin
    document.querySelector('input[value="Submit"]').click()
  ,
    uid: uid
    pin: pin
  
casper.then ->
  #this.log 'Last login: ' + this.evaluate ->
  #  $(window.frames[0].frames[3].document).find('.MFBodyTextBold:first').html()
  this.page.switchToChildFrame(0)
  this.page.switchToChildFrame(3)
  this.clickLabel ' View all My Accounts ', 'a'

casper.then ->
  this.clickLabel 'POSB Savings', 'a'

casper.then ->
  this.page.switchToChildFrame(0)
  this.page.switchToChildFrame(3)
  otp = this.cli.get(2)
  this.evaluate (otp)->
    document.querySelector('input[name="OTPToken"]').value = otp
    document.querySelector('input[name="submitButton"]').click()
  ,
    otp: otp

casper.then ->
  this.page.switchToChildFrame(0)
  this.page.switchToChildFrame(3)
  # this.log 'Body Inner Text: ' + this.evaluate ->
  #   document.body.innerText
  #   $('form[name="DownLoadTransactionHistoryForm"] input').length
  inputs = this.evaluate ->
    inputs = {}
    inputs['action'] = $('form[name="DownLoadTransactionHistoryForm"]:first').attr('action')
    $('form[name="DownLoadTransactionHistoryForm"] input').each ->
      inputs[$(this).attr('name')] = $(this).val()
    # downLoadTransaction begins
    inputs['TXN_DATES'] = txnDates.join(',')
    #inputs['TXN_VALUE_DATES'] = '1'
    inputs['TXN_CODES'] = txnCodes.join(',')
    inputs['TXN_REFERENCE_NUMBER1'] = txnReferencesNumber1.join(',')
    inputs['TXN_REFERENCE_NUMBER2'] = txnReferencesNumber2.join(',')
    inputs['TXN_REFERENCE_NUMBER3'] = txnReferencesNumber3.join(',')
    inputs['TXN_DEBITS'] = txnDebits.join(',')
    inputs['TXN_CREDITS'] = txnCredits.join(',')
    # downLoadTransaction ends
    inputs
  # this.log 'JSON: ' + JSON.stringify(inputs)

  resp = this.base64encode inputs['action'], 'POST', inputs
  fs = require 'fs'
  dest = if this.cli.has(3) then this.cli.get(3) else 'posb.csv'
  fs.write dest, window.atob(resp), 'w'

casper.run()
