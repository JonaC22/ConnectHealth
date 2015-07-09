var result = {};

var error_function = function(XMLHttpRequest, textStatus, errorThrown) {
    if (XMLHttpRequest.readyState == 4) {
        // HTTP error (can be checked by XMLHttpRequest.status and XMLHttpRequest.statusText)
        alert("Ha ocurrido un error en la transacción con el servidor");
    }
    else if (XMLHttpRequest.readyState == 0) {
        // Network error (i.e. connection refused, access denied due to CORS, etc.)
        alert("Ha ocurrido un error de conexión, verifique si está conectado a su proveedor de internet");
    }
    else {
        alert("Ha ocurrido un error, por favor intente nuevamente o comuniquese con el responsable");
    }
}

function set_query() {

console.log(JSON.stringify(result));
$.ajax({
    url: 'api/statistics',
    type: 'POST',
    contentType: 'application/json',
    data: JSON.stringify(result),
        // processData: false, // this is optional
        dataType: 'json',
        error: error_function
    }).done(function( data ) {

        if ( console && console.log ) {
            console.log(data);
        }
        if(data.err_number == 200) {
            alert(data.desc)
        }else{
            alert("Error:" + data.desc)
        }
    });
}

angular.module('statistics', [])
.controller('StatisticsController', ['$scope', function($scope) {
 

}]);

