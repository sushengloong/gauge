$ ->
  dashboard_gauges = new Array(4)
  for i in [1..dashboard_gauges.length] by 1
    dashboard_gauges[i] = new JustGage
      id: "dashboard-gauge-" + i
      value: 67
      min: 0
      max: 100
      title: ' '
      gaugeWidthScale: 0.4
