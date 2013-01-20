$ ->
  dashboard_gauges = new Array(4)
  for i in [1..dashboard_gauges.length] by 1
    dashboard_gauges[i] = new JustGage
      id: "dashboard-gauge-" + i
      value: 67
      min: 0
      max: 100
      title: '128 days'
      gaugeWidthScale: 0.4

  # smart sticky nav bar
  offset_top = $('#navbar').offset().top
  navbar_height = $('#navbar').height()
  $(window).scroll ->
    if $(window).scrollTop() > offset_top
      $('#navbar').addClass('navbar-fixed-top').next().css('padding-top', navbar_height+'px')
    else
      $('#navbar').removeClass('navbar-fixed-top').next().css('padding-top', '0px')
