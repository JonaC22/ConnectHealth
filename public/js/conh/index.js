function updateClock() {
    var currentTime = new Date();
    var currentHours = currentTime.getHours();
    var currentMinutes = currentTime.getMinutes();
    var currentSeconds = currentTime.getSeconds();

    // Pad the minutes and seconds with leading zeros, if required
    currentMinutes = ( currentMinutes < 10 ? "0" : "" ) + currentMinutes;
    currentSeconds = ( currentSeconds < 10 ? "0" : "" ) + currentSeconds;

    // Choose either "AM" or "PM" as appropriate
//    var timeOfDay = ( currentHours < 12 ) ? "AM" : "PM";

    // Convert the hours component to 12-hour format if needed
//    currentHours = ( currentHours > 12 ) ? currentHours - 12 : currentHours;

    // Convert an hours component of "0" to "12"
    currentHours = ( currentHours == 0 ) ? 12 : currentHours;

    // Compose the string for display
    var currentTimeString = currentHours + ":" + currentMinutes + ":" + currentSeconds;


    $("#clock").html(currentTimeString);
    $("#date").html(new Date().toJSON().slice(0,10));

}
updateClock();
$(document).ready(function () {
    setInterval('updateClock()', 1000);
});
createAgenda();
function createAgenda(){
    var d2 = new Date ();
    d2.setMinutes ( d2.getMinutes() >=30 ? 30 : 0);
    console.log(d2);
    for(d2;d2.getHours()<19; d2 = new Date(d2.getTime() + 30*60000)){
        console.log(d2);
        var currentHours = d2.getHours();
        var currentMinutes = d2.getMinutes();
        currentMinutes = ( currentMinutes < 10 ? "0" : "" ) + currentMinutes;
        var time = currentHours + ":" + currentMinutes;
        if(d2.getMinutes() == 0) {
            $('.timeline').append('<article class="timeline-item">' +
                '        <div class="timeline-caption">' +
                '        <div class="panel">' +
                '            <div class="panel-body">' +
                '                <span class="arrow left"></span>' +
                '                <span class="timeline-icon"><i class="fa fa-male time-icon bg-primary"></i></span>' +
                '                <span class="timeline-date">'+time+'</span>' +
                '                <h5>' +
                '                    <span>Consulta Médica</span>' +
                '                Juan Castro' +
                '                </h5>' +
                '            </div>' +
                '        </div>' +
                '        </div>' +
                '    </article>');
        }else {
            $('.timeline').append('<article class="timeline-item alt">' +
                '        <div class="timeline-caption">' +
                '        <div class="panel">' +
                '            <div class="panel-body">' +
                '                <span class="arrow right"></span>' +
                '                <span class="timeline-icon"><i class="fa fa-male time-icon bg-success"></i></span>' +
                '                <span class="timeline-date">'+time+'</span>' +
                '                <h5>' +
                '                    <span>Consulta Médica</span>' +
                '                Karen Molina' +
                '                </h5>' +
                '            </div>' +
                '        </div>' +
                '        </div>' +
                '    </article>');
        }
    }


    $('.timeline').append('<div class="timeline-footer"><a><i class="fa fa-plus time-icon inline-block bg-dark"></i></a></div>');
}
