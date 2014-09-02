function generate_lesson_chart(chartId,chartName,xAxisArray,serie)
{

	// Chart generation
	window.chart = new Highcharts.Chart({
	            
	    chart: {
	        renderTo: chartId,
            type: 'column'
	    },
	    
	    title: {
	        text: chartName,
	        x: 0,
	    },
	    
	    xAxis: {
            type: 'category',
	        categories: xAxisArray,
	        labels: {
                rotation: -45,
                style: {
                    fontSize: '13px',
                    fontFamily: 'Verdana, sans-serif'
                }
            }
	    },
	        
	    yAxis: {
            title: {
                text: 'Count'
            },
            lineWidth: 0,
			max: 3
	    },
	    
	    tooltip: {
            pointFormat: '<b>{point.y:.1f} </b>'
	    },
	    
	    legend: {
            enabled: false
	    },
	    credits : {
		  enabled : false
		},
		exporting : {
			url : "http://toulouse.sqli.com/eisq-portal/export_image/index.php"
		},
	    series: [{
	        name: 'Reference',
	        color: '#99B3FF',
	        data: serie
	    }]
	});
}