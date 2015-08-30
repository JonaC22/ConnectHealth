/* [ Yukon Admin - form validation ] */

	yukon_form_validation = {
		init: function() {
            // wysiwg editor
            yukon_wysiwg.init();
            // multiselect
            yukon_multiselect.init();
            // validation
            yukon_parsley_validation.init();
        }
	};

    // validation
    yukon_parsley_validation = {
        init: function() {
            $('#form_validation').parsley();
        }
    };

	// wysiwg editor
	yukon_wysiwg = {
		init: function() {
			if ($('#val_textarea_message').length) {
				var editor_validate = $('textarea#val_textarea_message').ckeditor();
			}
		}
	};

    // multiselect
	yukon_multiselect = {
		init: function() {
			if($('#val_select').length) {
				$('#val_select').select2({
					allowClear: true,
					placeholder: "Select..."
				});
			}
		}
	};
