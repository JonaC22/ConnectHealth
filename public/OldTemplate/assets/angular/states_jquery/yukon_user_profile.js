/* [ Yukon Admin - user profile ] */

    yukon_user_profile = {
        init: function() {
            // easy chart pie
            if($('.easy_chart_user_tasks').length) {
				$('.easy_chart_user_tasks').easyPieChart({
					animate: 2000,
					size: 60,
					lineWidth: 3,
					scaleColor: false,
					barColor: '#48ac2e',
					trackColor: '#ddd',
					easing: 'easeOutBounce'
				});
			}
            if($('.easy_chart_user_mails').length) {
				$('.easy_chart_user_mails').easyPieChart({
					animate: 2000,
					size: 60,
					lineWidth: 3,
					scaleColor: false,
					barColor: '#c0392b',
					trackColor: '#ddd',
					easing: 'easeOutBounce',
					onStep: function(from, to, percent) {
						$(this.el).children('.easy_chart_percent_text').html(Math.round(percent) + '%<small>Mails</small>');
					}
				});
			}
            if($('.easy_chart_user_sale').length) {
				$('.easy_chart_user_sale').easyPieChart({
					animate: 2000,
					size: 60,
					lineWidth: 3,
					scaleColor: false,
					barColor: '#4a89dc',
					trackColor: '#ddd',
					easing: 'easeOutBounce',
					onStep: function(from, to, percent) {
						$(this.el).children('.easy_chart_percent').html(Math.round(percent) + '%');
					}
				});
			}
        }
    };
