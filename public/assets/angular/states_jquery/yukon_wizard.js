/* [ Yukon Admin - wizard ] */

	yukon_wizard = {
		init: function() {
            // wizard
            yukon_steps.init();
            // select country
            yukon_select.country();
            // select languages
            yukon_select.languages();
            // form validation
            yukon_validation.init();
        }
    };
	
	// wizard
	yukon_steps = {
		init: function() {
			if ($("#wizard_101").length) {
				// initialize wizard
				$("#wizard_101").steps({
					headerTag: 'h3',
					bodyTag: "section",
					titleTemplate: "<span class=\"title\">#title#</span>",
					enableAllSteps: true,
					enableFinishButton: false,
					transitionEffect: "slideLeft",
					labels: {
						next: "Next <i class=\"fa fa-angle-right\"></i>",
						previous: "<i class=\"fa fa-angle-left\"></i> Previous",
						current: "",
						finish: "Agree"
					},
					onStepChanged: function (event, currentIndex, priorIndex) {
						// adjust wizard height
						yukon_steps.setContentHeight('#wizard_101')
					} 
				});
				// set initial wizard height
				yukon_steps.setContentHeight('#wizard_101');
                // rezie wizard on window resize
                $(window).on('resize',function() {
                    yukon_steps.setContentHeight('#wizard_101');
                })
			}
			if ($("#wizard_form").length) {
				var wizard_form = $('#wizard_form');
				// initialize wizard
				wizard_form.steps({
					headerTag: 'h3',
					bodyTag: "section",
					enableAllSteps: true,
					titleTemplate: "<span class=\"title\">#title#</span>",
					transitionEffect: "slideLeft",
					labels: {
						next: "Next Step <i class=\"fa fa-angle-right\"></i>",
						previous: "<i class=\"fa fa-angle-left\"></i> Previous Step",
						current: "",
						finish: "<i class=\"fa fa-check\"></i> Register"
					},
					onStepChanging: function (event, currentIndex, newIndex) {
						var cursentStep = wizard_form.find('.content > .body').eq(currentIndex);
						// check input fields for errors
						cursentStep.find('[data-parsley-id]').each(function() {
							$(this).parsley().validate();
						});
                        
						return cursentStep.find('.parsley-error').length ? false : true;
					},
					onStepChanged: function (event, currentIndex, priorIndex) {
						thisIndex = currentIndex;
						// adjust wizard height
						yukon_steps.setContentHeight('#wizard_form');
					},
					onFinishing: function (event, currentIndex) {
						var cursentStep = wizard_form.find('.content > .body').eq(currentIndex);
						// check input fields for errors
						cursentStep.find('[data-parsley-id]').each(function() {
							$(this).parsley().validate();
						});

                        return cursentStep.find('.parsley-error').length ? false : true;
					},
					onFinished: function(event, currentIndex) {
						alert("Submitted!");
                        //* uncomment the following line to submit form
                        //wizard_form.submit();
					}
				});
				// set initial wizard height
				yukon_steps.setContentHeight('#wizard_form');
                // rezie wizard on window resize
                $(window).on('resize',function() {
                    yukon_steps.setContentHeight('#wizard_form');
                })
            }
        },
		setContentHeight: function($wizard) {
			setTimeout(function() {
				var cur_height = $($wizard).children('.content').children('.body.current').outerHeight();
				$($wizard).find('.content').height(cur_height);
			},0);
		}
	};

    // validation
	yukon_validation = {
		init: function() {
            $('#wizard_validation').parsley();
			var thisIndex = 0;
			$.listen('parsley:field:validate', function(e) {
				yukon_steps.setContentHeight('#'+e.$element.closest('div.wizard').attr('id'));
			});
		}
	};

	// select country
	yukon_select = {
		country: function() {
			if($('#s2_country').length) {
				function format(state) {
					if (!state.id) return state.text;
					return '<i class="flag-' + state.id + '"></i>' + state.text;
				}
				$('#s2_country').select2({
					placeholder: "Select Country",
					formatResult: format,
					formatSelection: format,
					escapeMarkup: function(markup) { return markup; }
				});
			}
		},
		languages: function() {
			if($('#s2_languages').length) {
				$('#s2_languages').select2({
					placeholder: "Select language",
					tags:["Mandarin", "Spanish", "English", "Hindi", "Arabic", "Portuguese"],
					tokenSeparators: [",", " "]
				});
			}
		}
	};