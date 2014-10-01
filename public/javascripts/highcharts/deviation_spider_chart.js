// Chart generation
function generate_spider_chart(chartId,chartName,chartData)
{
	// Chart generation
	return new Highcharts.Chart({
	            
	    chart: {
	        renderTo: chartId,
	        polar: true,
	        type: 'area'
	    },
	    
	    title: {
	        text: chartName,
	        x: 0,
	    },
	    
	    pane: {
	    	size: '80%'
	    },
	    
	    xAxis: {
	        categories: chartData.titles,
	        tickmarkPlacement: 'on',
	        lineWidth: 0
	    },
	        
	    yAxis: {
	        gridLineInterpolation: 'polygon',
	        lineWidth: 0,
			max: 1,
	        min: 0
	    },
	    
	    tooltip: {
	    	shared: true,
	        valuePrefix: ''
	    },
	    
	    legend: {
	        align: 'right',
	        verticalAlign: 'top',
	        y: 100,
	        layout: 'vertical'
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
	        data: chartData.points_ref,
	        pointPlacement: 'on'
	    },
		{
	        name: 'Note',
	        color: '#0E13FF',
	        data: chartData.points,
	        pointPlacement: 'on'
	    }]
	});
}

// Charts objects
function generate_chart_data_object()
{
	var chart_data = new Object();
	chart_data.titles 		= Array();
	chart_data.points 		= Array();
	chart_data.points_ref 	= Array();
	return chart_data;
}

function parse_chart_data(msg)
{
	chart_data_from_json = $.parseJSON(msg);
	var chart_data = generate_chart_data_object();
	if (chart_data_from_json.length == 3) {
		chart_data.titles 		= chart_data_from_json[0];
		chart_data.points 		= chart_data_from_json[1];
		chart_data.points_ref 	= chart_data_from_json[2];
	}
	return chart_data;
}

// Chart requests
function show_deliverable_chart_data(deviation_spider_id, meta_activity_id)
{
	$.ajax({
		type: "POST",
		url: "/deviation_spiders/get_deliverable_chart",
 		data: {deviation_spider_id: deviation_spider_id, meta_activity_id: meta_activity_id}
	})
	.done(function( msg ) {
		// console.log(parse_chart_data(msg));
		if (chart_deliverable == null) {
			chart_deliverable = generate_spider_chart("deviation_spider_chart_deliverable", "deviation_spider_chart_deliverable", parse_chart_data(msg));
		} else {
			chart_data_object = parse_chart_data(msg);
			chart_deliverable.series[0].setData(chart_data_object.points_ref,true);
			chart_deliverable.series[1].setData(chart_data_object.points,true);
		}
	})
	.fail(function() 
	{ 
		alert("Error");
	})
}

function show_activity_chart_data(deviation_spider_id, meta_activity_id)
{
	$.ajax({
		type: "POST",
		url: "/deviation_spiders/get_activity_chart",
 		data: {deviation_spider_id: deviation_spider_id, meta_activity_id: meta_activity_id}
	})
	.done(function( msg ) {
		if (chart_activity == null) {
			chart_activity = generate_spider_chart("deviation_spider_chart_activity", "deviation_spider_chart_activity", parse_chart_data(msg));
		} else {
			chart_data_object = parse_chart_data(msg);
			chart_activity.series[0].setData(chart_data_object.points_ref,true);
			chart_activity.series[1].setData(chart_data_object.points,true);
		}
	})
	.fail(function() 
	{ 
		alert("Error");
	})
}