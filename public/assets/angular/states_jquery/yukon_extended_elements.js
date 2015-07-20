/* [ Yukon Admin - extended elements ] */

	yukon_extended_elements = {
        init: function() {
            // select2
            yukon_enh_select.init();
            // datepicker
            yukon_datepicker.init();
            // date range picker
            yukon_date_range_picker.init();
            // rangeSlider
            yukon_rangeSlider.init();
            // textarea autosize
            yukon_autosize.init();
            // masked inputs
            yukon_maskedInputs.init();
            // maxlength for textareas
            yukon_maxlength.init();
            // uplaoder
            yukon_uploader.init();
            // 2col multiselect
            yukon_2col_multiselect.init();
            // clock picker
            yukon_clock_picker.init();
            // chained selects
            yukon_chained_selects.init();
            // password show/hide
            yukon_pwd_show_hide.init();
            // password strength metter
            yukon_pwd_strength_metter.init();
            // checkboxes & radio buttons
	        yukon_icheck.init();
            // selectize.js
            yukon_selectize.init();
            // wysiwg editor
            yukon_wysiwg.init();
        }
	};
	
	// select2
	yukon_enh_select = {
		init: function() {
			if ($("#s2_basic").length) {
				$("#s2_basic").select2({
					allowClear: true,
					placeholder: "Select..."
				});
			}
			if ($("#s2_multi").length) {
				$("#s2_multi").select2({
					placeholder: "Select..."
				});
			}
			if($('#s2_tokenization').length) {
				$('#s2_tokenization').select2({
					placeholder: "Select...",
					tags:["red", "green", "blue", "black", "orange", "white"],
					tokenSeparators: [",", " "]
				});
			}
			if($('#s2_ext_value').length) {
				
				function format(state) {
					if (!state.id) return state.text;
					return '<i class="flag-' + state.id + '"></i>' + state.text;
				}
				
				$('#s2_ext_value').select2({
					placeholder: "Select Country",
					formatResult: format,
					formatSelection: format,
					escapeMarkup: function(markup) { return markup; }
				}).val("AU").trigger("change");
				
				$("#s2_ext_us").click(function(e) { e.preventDefault(); $("#s2_ext_value").val("US").trigger("change"); });
				$("#s2_ext_br_gb").click(function(e) { e.preventDefault(); $("#s2_ext_value").val(["JP","PL"]).trigger("change"); });
			}
			if($('#s2_load_data').length) {
				$("#s2_load_data").select2({
					data:[
						{id:0,text:'enhancement'},
						{id:1,text:'bug'},
						{id:2,text:'duplicate'},
						{id:3,text:'invalid'},
						{id:4,text:'wontfix'}
					]
				});
			}
		}
	};
	
	// datepicker
	yukon_datepicker = {
		init: function() {
			if ( $.isFunction($.fn.datepicker) ) {
				// replace datepicker arrow
				$.fn.datepicker.DPGlobal.template = $.fn.datepicker.DPGlobal.template
				.replace(/\&laquo;/g, '<i class="arrow_carrot-left"></i>')
				.replace(/\&raquo;/g, '<i class="arrow_carrot-right"></i>');
			}
			  
			if ($("#dp_basic").length) {
				$("#dp_basic").datepicker({
					autoclose: true	
				});
			}
			if ($("#dp_component").length) {
				$("#dp_component").datepicker({
					autoclose: true	
				});
			}
			if ($("#dp_range").length) {
				$("#dp_range").datepicker({
					autoclose: true
				});
			}
			if ($("#dp_inline").length) {
				$("#dp_inline").datepicker();
			}
		}
	};
	
	// date range picker
	yukon_date_range_picker = {
		init: function() {
			if ($("#drp_time").length) {
				$('#drp_time').daterangepicker({
                    timePicker: true,
                    timePickerIncrement: 30,
                    format: 'MM/DD/YYYY h:mm A',
                    buttonClasses: 'btn btn-sm'
                });
			}
			if ($("#drp_predefined").length) {
				$('#drp_predefined').daterangepicker(
				{
					ranges: {
					   'Today': [moment(), moment()],
					   'Yesterday': [moment().subtract('days', 1), moment().subtract('days', 1)],
					   'Last 7 Days': [moment().subtract('days', 6), moment()],
					   'Last 30 Days': [moment().subtract('days', 29), moment()],
					   'This Month': [moment().startOf('month'), moment().endOf('month')],
					   'Last Month': [moment().subtract('month', 1).startOf('month'), moment().subtract('month', 1).endOf('month')]
					},
					startDate: moment().subtract('days', 29),
					endDate: moment()
				},
				function(start, end) {
					$('#drp_predefined span').html(start.format('MMMM D, YYYY') + ' - ' + end.format('MMMM D, YYYY'));
				}
				);
			}
		}
	};
	
	// rangeSlider
	yukon_rangeSlider = {
		init: function() {
			if ($("#rS_exm_1").length) {
				$("#rS_exm_1").ionRangeSlider({
					min: 0,
					max: 5000,
					from: 1200,
					to: 2450,
					type: 'double',
					prefix: "$",
					maxPostfix: "+",
					prettify: false,
					hasGrid: true
				});
                $(window).on('resize',function() {
                    $("#rS_exm_1").ionRangeSlider("update")
                })
			}
			if ($("#rS_exm_2").length) {
				$("#rS_exm_2").ionRangeSlider({
					min: 1000,
					max: 100000,
					from: 30000,
					to: 90000,
					type: 'double',
					step: 500,
					postfix: " €",
					hasGrid: true
				});
                $(window).on('resize',function() {
                    $("#rS_exm_2").ionRangeSlider("update")
                })
			}
			if ($("#rS_exm_3").length) {
				$("#rS_exm_3").ionRangeSlider({
					min: 0,
					max: 10,
					type: 'single',
					step: 0.1,
					postfix: " carats",
					prettify: false,
					hasGrid: true
				});
                $(window).on('resize',function() {
                    $("#rS_exm_3").ionRangeSlider("update")
                })
			}
			if ($("#rS_exm_4").length) {
				$("#rS_exm_4").ionRangeSlider({
					min: -50,
					max: 50,
					from: 0,
					postfix: "°",
					prettify: false,
					hasGrid: true
				});
                $(window).on('resize',function() {
                    $("#rS_exm_4").ionRangeSlider("update")
                })
			}
			if ($("#rS_exm_5").length) {
				$("#rS_exm_5").ionRangeSlider({
					min: 10000,
					max: 100000,
					step: 100,
					postfix: " km",
					from: 55000,
					hideMinMax: true,
					hideFromTo: false
				});
                $(window).on('resize',function() {
                    $("#rS_exm_5").ionRangeSlider("update")
                })
			}
		}
	};

    // textarea autosize
    yukon_autosize = {
        init: function() {
            if($('#autosize_a').length) {
                $('#autosize_a').autosize();
            }
        }
    };

    // masked inputs
    yukon_maskedInputs = {
        init: function() {
            $("#mask_date").inputmask("dd/mm/yyyy",{ "placeholder": "dd/mm/yyyy", showMaskOnHover: false });
            $("#mask_phone").inputmask("mask", {"mask": "(999) 999-9999"});
            $("#mask_plate").inputmask({"mask": "[9-]AAA-999"});
            $("#mask_numeric").inputmask('€ 999.999,99', { numericInput: false });
            $("#mask_mac").inputmask({"mask": "**:**:**:**:**:**"});
            $("#mask_callback").inputmask("mm/dd/yyyy",{ "placeholder": "mm/dd/yyyy", "oncomplete": function(){ alert('Date entered: '+$(this).val()); } });
            $('[data-inputmask]').inputmask();
        }
    };

    // maxLength for Textareas
    yukon_maxlength = {
        init: function() {
            if($('#ml_default').length) {
                $('#ml_default').stopVerbosity({
                    limit: 20,
                    existingIndicator: $('#ml_default_indicator')
                });
            }
            if($('#ml_custom').length) {
                $('#ml_custom').stopVerbosity({
                    limit: 32,
                    existingIndicator: $('#ml_custom_indicator'),
                    indicatorPhrase: [
                        'This is a custom indicator phrase.',
                        'This one only counts down. Only', '<span class="label label-primary">[countdown]</span>', 'characters', 'left.'
                    ]
                })
            }
        }
    };

    // uploader
    yukon_uploader = {
        init: function() {
            if($('#uploader').length) {
                $("#uploader").pluploadQueue({
                    // General settings
                    runtimes : 'html5,flash,silverlight,html4',
                    url : "/upload",

                    chunk_size : '1mb',
                    rename : true,
                    dragdrop: true,

                    filters : {
                        // Maximum file size
                        max_file_size : '10mb',
                        // Specify what files to browse for
                        mime_types: [
                            {title : "Image files", extensions : "jpg,gif,png"},
                            {title : "Zip files", extensions : "zip"}
                        ]
                    },

                    // Resize images on clientside if we can
                    resize: {
                        width : 200,
                        height : 200,
                        quality : 90,
                        crop: true // crop to exact dimensions
                    },


                    // Flash settings
                    flash_swf_url : 'assets/lib/plupload/js/Moxie.swf',

                    // Silverlight settings
                    silverlight_xap_url : 'assets/lib/plupload/js/Moxie.xap'
                });
            }
        }
    };

	// wysiwg editor
	yukon_wysiwg = {
		init: function() {
			if ($('#wysiwg_editor').length) {
				$('#wysiwg_editor').ckeditor();
			}
		}
	};

    // 2col multiselect
    yukon_2col_multiselect = {
        init: function() {
            if($('#2col_ms_default').length) {
                var $msListDefault = $('#2col_ms_default');
                $msListDefault.multiSelect({
                    keepOrder: true,
                    selectableHeader: '<div class="ms-header">Selectable items</div>',
                    selectionHeader: '<div class="ms-header">Selection items</div>',
                    selectableFooter: '<div class="ms-footer">Selectable footer</div>',
                    selectionFooter: '<div class="ms-footer">Selection footer</div>'
                });
                $msListDefault.closest('.ms-wrapper').find('.ms_select_all').click(function (e) {
                    e.preventDefault();
                    $msListDefault.multiSelect('select_all');
                });
                $msListDefault.closest('.ms-wrapper').find('.ms_deselect_all').click(function (e) {
                    e.preventDefault();
                    $msListDefault.multiSelect('deselect_all');
                });
            }
            if($('#2col_ms_search').length) {
                var $msListSearch = $('#2col_ms_search');
                $msListSearch.multiSelect({
                    keepOrder: true,
                    selectableHeader: '<div class="ms-header-search"><input class="form-control input-sm" type="text" placeholder="Search in selectable..."/></div>',
                    selectionHeader: '<div class="ms-header-search"><input class="form-control input-sm" type="text" placeholder="Search in selection..."/></div>',
                    afterInit: function(ms){
                        ms.find('.ms-list li').each(function() {
                            var thisText = $(this).children('span').text(),
                                flag = thisText.substr(2, 2),
                                flag_remove = thisText.substr(0, 6);
                            $(this).children('span').html( '<i class="flag-'+ flag +'"></i>'+ thisText.replace(flag_remove,'') );
                        });
                        var that = this,
                            $selectableSearch = that.$selectableUl.prev().children(),
                            $selectionSearch = that.$selectionUl.prev().children(),
                            selectableSearchString = '#' + that.$container.attr('id') + ' .ms-elem-selectable:not(.ms-selected)',
                            selectionSearchString = '#' + that.$container.attr('id') + ' .ms-elem-selection.ms-selected';

                        that.qs1 = $selectableSearch.quicksearch(selectableSearchString).on('keydown', function (e) {
                            if (e.which === 40) {
                                that.$selectableUl.focus();
                                return false;
                            }
                        });

                        that.qs2 = $selectionSearch.quicksearch(selectionSearchString).on('keydown', function (e) {
                            if (e.which == 40) {
                                that.$selectionUl.focus();
                                return false;
                            }
                        });
                    },
                    afterSelect: function () {
                        this.qs1.cache();
                        this.qs2.cache();
                    },
                    afterDeselect: function () {
                        this.qs1.cache();
                        this.qs2.cache();
                    }
                });
                $msListSearch.closest('.ms-wrapper').find('.ms_select_all').click(function (e) {
                    e.preventDefault();
                    $msListSearch.multiSelect('select_all');
                });
                $msListSearch.closest('.ms-wrapper').find('.ms_deselect_all').click(function (e) {
                    e.preventDefault();
                    $msListSearch.multiSelect('deselect_all');
                });
            }
        }
    };

    // clock picker
    yukon_clock_picker = {
        init: function() {
            $('.clockpicker').clockpicker()
                .find('input').change(function(){
                    console.log(this.value);
                });
        }
    };

    // chained selects
    yukon_chained_selects = {
        init: function() {
            $("#chs_button").hide();
            $("#chs_series").chained("#chs_mark");
            $("#chs_model").chained("#chs_series");
            $("#chs_engine").chained("#chs_series, #chs_model").on("change", function() {
                if ("" != $("option:selected", this).val() && "" != $("option:selected", $("#chs_model")).val()) {
                    $("#chs_button").fadeIn();
                } else {
                    $("#chs_button").hide();
                }
            });
        }
    };

    // password show/hide
    yukon_pwd_show_hide = {
        init: function() {
            if($('#pwdSt_password').length) {
                $('#pwdSt_password').hidePassword(true);
            }
        }
    };

    // password strength metter
    yukon_pwd_strength_metter = {
        init: function() {
            if($('#pwdSt_password').length) {
                var options = {};
                options.ui = {
                    verdicts: ["Weak", "Normal", "Medium", "Strong", "Very Strong"],
                    container: "#pwd-container",
                    showVerdictsInsideProgressBar: true,
                    viewports: {
                        progress: ".pwstrength_viewport_progress"
                    }
                };
                $('#pwdSt_password').pwstrength(options);
            }
        }
    };

    // checkboxes & radio buttons
	yukon_icheck = {
		init: function() {
			if($('.icheck').length) {
				$('.icheck').iCheck({
					checkboxClass: 'icheckbox_minimal-blue',
					radioClass: 'iradio_minimal-blue'
				});
			}
		}
	};

    // selectize.js
	yukon_selectize = {
		init: function() {
			if($('#slz_optgroups').length) {
				$('#slz_optgroups').selectize({
                    sortField: 'text'
                });
			}
            if($('#slz_contacts').length) {
                var REGEX_EMAIL = '([a-z0-9!#$%&\'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&\'*+/=?^_`{|}~-]+)*@' +
                  '(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?)';

                var formatName = function(item) {
                    return $.trim((item.first_name || '') + ' ' + (item.last_name || ''));
                };

                $('#slz_contacts').selectize({
                    persist: false,
                    maxItems: null,
                    valueField: 'email',
                    labelField: 'name',
                    searchField: ['first_name', 'last_name', 'email'],
                    sortField: [
                        {field: 'first_name', direction: 'asc'},
                        {field: 'last_name', direction: 'asc'}
                    ],
                    options: [
                        {email: 'nikola@tesla.com', first_name: 'Nikola', last_name: 'Tesla'},
                        {email: 'brian@thirdroute.com', first_name: 'Brian', last_name: 'Reavis'},
                        {email: 'someone@gmail.com'}
                    ],
                    render: {
                        item: function(item, escape) {
                            var name = formatName(item);
                            return '<div>' +
                                (name ? '<span class="name">' + escape(name) + '</span>' : '') +
                                (item.email ? '<span class="email">' + escape(item.email) + '</span>' : '') +
                            '</div>';
                        },
                        option: function(item, escape) {
                            var name = formatName(item);
                            var label = name || item.email;
                            var caption = name ? item.email : null;
                            return '<div>' +
                                '<span class="label">' + escape(label) + '</span>' +
                                (caption ? '<span class="caption">' + escape(caption) + '</span>' : '') +
                            '</div>';
                        }
                    },
                    createFilter: function(input) {
                        var regexpA = new RegExp('^' + REGEX_EMAIL + '$', 'i');
                        var regexpB = new RegExp('^([^<]*)\<' + REGEX_EMAIL + '\>$', 'i');
                        return regexpA.test(input) || regexpB.test(input);
                    },
                    create: function(input) {
                        if ((new RegExp('^' + REGEX_EMAIL + '$', 'i')).test(input)) {
                            return {email: input};
                        }
                        var match = input.match(new RegExp('^([^<]*)\<' + REGEX_EMAIL + '\>$', 'i'));
                        if (match) {
                            var name       = $.trim(match[1]);
                            var pos_space  = name.indexOf(' ');
                            var first_name = name.substring(0, pos_space);
                            var last_name  = name.substring(pos_space + 1);

                            return {
                                email: match[2],
                                first_name: first_name,
                                last_name: last_name
                            };
                        }
                        alert('Invalid email address.');
                        return false;
                    }
                });
            }
            if($('#slz_remove_btn').length) {
				$('#slz_remove_btn').selectize({
                    plugins: ['remove_button'],
                    persist: false,
                    create: true,
                    render: {
                        item: function(data, escape) {
                            return '<div>"' + escape(data.text) + '"</div>';
                        }
                    },
                    onDelete: function(values) {
                        return confirm(values.length > 1 ? 'Are you sure you want to remove these ' + values.length + ' items?' : 'Are you sure you want to remove "' + values[0] + '"?');
                    }
                });
			}
		}
	};