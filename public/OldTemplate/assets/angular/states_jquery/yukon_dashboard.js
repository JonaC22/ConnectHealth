/* [ Yukon Admin - dashboard ] */

    yukon_dashboard = {
        init: function() {
            // countUp animation
            yukon_count_up.init();
            // easyPie chart
            yukon_easyPie_chart.init();
            // c3 charts
            yukon_charts.sale_7_days();
            //yukon_charts.departments();
            yukon_charts.orders();
            yukon_charts.users_age();
            // vector maps
            yukon_vector_maps.init();
            // match height
            yukon_matchHeight.init();
        }
    };

	// vector maps
	yukon_vector_maps = {
		init: function() {
			if($('#world_map_vector').length) {
				$('#world_map_vector').vectorMap({
					map: 'world_mill_en',
					backgroundColor: 'transparent',
					regionStyle: {
						initial: {
							fill: '#c8c8c8'
						},
						hover: {
							"fill-opacity": 1
						}
					},
					series: {
						regions: [{
							values: countries_data,
							scale: ['#58bbdf', '#1c7393'],
							normalizeFunction: 'polynomial'
						}]
					},
					onRegionLabelShow: function(e, el, code){
						if(typeof countries_data[code] == 'undefined') {
							e.preventDefault();
						} else {
							var countryLabel = countries_data[code];
							el.html(el.html()+': '+countryLabel+' visits');
						}
					}
				});
			}   
		}
	};
	
	// c3 charts
	yukon_charts = {
		sale_7_days: function() {
			
			var chart_c3_sales = c3.generate({
                bindto: '#c3_sales',
				data: {
					x: 'x',
					columns: [
						['x', '2013-01-01', '2013-02-01', '2013-03-01', '2013-04-01', '2013-05-01', '2013-06-01', '2013-07-01', '2013-08-01', '2013-09-01', '2013-10-01', '2013-11-01', '2013-12-01'],
						['2013', 14512, 10736, 18342, 14582, 16304, 22799, 18833, 21973, 23643, 22488, 24752, 28722],
                        ['2014', 23732, 22904, 23643, 26887, 32629, 30512, 31658, 35782, 36724, 38947, 42426, 37439]
					],
					types: {
						'2013': 'area',
						'2014': 'line'
					}
				},
				axis: {
					x: {
						type: 'timeseries',
						tick: {
							culling: false,
							fit: true,
							format: "%b"
						}
					},
					y : {
						tick: {
							format: d3.format("$,")
						}
					}
				},
				point: {
					r: '4',
					focus: {
						expand: {
							r: '5'
						}
					}
				},
				bar: {
					width: {
						ratio: 0.4 // this makes bar width 50% of length between ticks
					}
				},
				grid: {
					x: {
						show: true
					},
					y: {
						show: true
					}
				},
				color: {
					pattern: ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd', '#8c564b', '#e377c2', '#7f7f7f', '#bcbd22', '#17becf']
				}
			});

			$('.chart_switch').on('click', function() {
				
				if($(this).data('chart') == 'line') {
                    chart_c3_sales.transform('area', '2013');
                    chart_c3_sales.transform('line', '2014');
				} else if($(this).data('chart') == 'bar') {	
					chart_c3_sales.transform('bar');
				}
				
				$('.chart_switch').toggleClass('btn-default btn-link');
				
			});

            $(window).on("debouncedresize", function() {
                chart_c3_sales.resize();
            });

		},
		orders: function() {
			var chart_c3_orders = c3.generate({
				bindto: '#c3_orders',
				data: {
					columns: [
						['New', 64],
						['In Progrees', 36]
						
					],
					type : 'pie'
				},
				pie: {
					onclick: function (d, i) { console.log(d, i); },
					onmouseover: function (d, i) { console.log(d, i); },
					onmouseout: function (d, i) { console.log(d, i); }
				}
			});
            $(window).on("debouncedresize", function() {
                chart_c3_orders.resize();
            });
		},
		users_age: function() {
			var chart_c3_users_age = c3.generate({
				bindto: '#c3_users_age',
				data: {
					columns: [
						['18-24', 18],
						['25-32', 42],
						['33-40', 31],
						['41-57', 9]
						
					],
					type : 'donut'
				},
				donut: {
					onclick: function (d, i) { console.log(d, i); },
					onmouseover: function (d, i) { console.log(d, i); },
					onmouseout: function (d, i) { console.log(d, i); }
				}
			});
            $(window).on("debouncedresize", function() {
                chart_c3_users_age.resize();
            });
		}
		
	};
	
	// countUp animation
	yukon_count_up = {
		init: function() {
			$('.countUpMe').each(function() {
				var target = this;
				var endVal = parseInt($(this).attr('data-endVal'));
				theAnimation = new countUp(target, 0, endVal, 0, 2.6, { useEasing : true, useGrouping : true, separator: ' ' });
				theAnimation.start();
			});
		}
	};
	
	// easyPie chart
	yukon_easyPie_chart = {
		init: function() {
			if($('.easy_chart_a').length) {
				$('.easy_chart_a').easyPieChart({
					animate: 2000,
					size: 90,
					lineWidth: 4,
					scaleColor: false,
					barColor: '#48ac2e',
					trackColor: '#eee',
					easing: 'easeOutBounce',
					onStep: function(from, to, percent) {
						$(this.el).children('.easy_chart_percent').text(Math.round(percent) + '%');
					}
				});
			}
			if($('.easy_chart_b').length) {
				$('.easy_chart_b').easyPieChart({
					animate: 2000,
					size: 90,
					lineWidth: 4,
					scaleColor: false,
					barColor: '#c0392b',
					trackColor: '#eee',
					easing: 'easeOutBounce',
					onStep: function(from, to, percent) {
					}
				});
			}
			if($('.easy_chart_c').length) {
				$('.easy_chart_c').easyPieChart({
					animate: 2000,
					size: 90,
					lineWidth: 4,
					scaleColor: false,
					barColor: '#4a89dc',
					trackColor: '#eee',
					easing: 'easeOutBounce',
					onStep: function(from, to, percent) {
					}
				});
			}
		}
	};

    // match height
    yukon_matchHeight = {
        init: function(){
            $('.mHeight').each(function() {
                $(this).find('.mHeight-item').matchHeight(true);
            });
            $(window).on('resize',function() {
                $.fn.matchHeight._update();
            })
        }
    };