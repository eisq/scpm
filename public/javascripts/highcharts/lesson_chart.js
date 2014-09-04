
function generate_lesson_complex_chart(chartId, chartName, xAxisArray, series)
{
// Chart generation

	window.chart = new Highcharts.Chart({
	            
	    chart: {
	        renderTo: chartId,
            marginRight: 500
	    },
	    
	    title: {
	        text: chartName,
	        x: 0,
	    },
	    
	    xAxis: {
            type: 'category',
	        categories: xAxisArray,
	        labels: {
                style: {
                    fontSize: '12px',
            		fontWeight: 'bold'
                }
            }
	    },
	        
	    yAxis: {
            title: {
                text: 'Count'
            },
			min: 0
	    },
	    
	    tooltip: {
            pointFormat: '<b>{point.y} </b>'
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
	    series: series
	});
}

function generate_lesson_chart(chartId,chartName,xAxisArray,serie, type)
{

	// Chart generation
	window.chart = new Highcharts.Chart({
	            
	    chart: {
	        renderTo: chartId,
            type: type
	    },
	    
	    title: {
	        text: chartName,
	        x: 0,
	    },
	    
	    xAxis: {
            type: 'category',
	        categories: xAxisArray,
	        labels: {
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
			min: 0
	    },
	    
	    tooltip: {
            pointFormat: '<b>{point.y} </b>'
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
	        name: 'Axes',
	        color: '#99B3FF',
	        data: serie
	    }]
	});
}