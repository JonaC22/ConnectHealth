/* [ Yukon Admin - chat] */

	// chat
	yukon_chat = {
		send_msg: function() {
		    var msg_date_unix;
            $('.chat_message_send button').on('click', function() {
                var msg_date = moment().format('MMM D YYYY, h:mm A'),
                    chat_msg = $('.chat_message_send textarea').val();
                if(chat_msg != '') {
                    if( msg_date != $('.chat_messages').data('lastMessageUnix') ) {
                        $('.chat_messages').prepend('<div class="message_date">'+ msg_date +'</div><ul></ul>').data('lastMessageUnix', msg_date);
                    }
                    $('.chat_messages ul:first').prepend('<li class="msg_left"><p class="msg_user">Carrol Clark</p>' + chat_msg + '</li>');
                    $('.chat_message_send textarea').val('');
                }
            })
		}
	};
