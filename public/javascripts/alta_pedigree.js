        var personas = [];
        var relations = [];
        var result = {};
        result.personas=personas;
        result.relations=relations;

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

        function agregarNodo (form) {
            var nodo = {};
            nodo.id = personas.length;
            nodo.nombre = form.nombre.value;
            nodo.edad = form.edad.value;
            nodo.sexo = form.sexo.value;
            personas.push(nodo);
            $("#listPeople").append('<li onclick="openRelation(this.value)" id="'+nodo.id+'" value="'+nodo.id+'">'+nodo.nombre + " Edad: " + nodo.edad+'</li>');
            console.log(nodo);
            console.log(personas);
//            alert ("Nodo agregado ");
}

function openRelation(nodoId){
    $("#listPeopleAvailable").empty();
    personas.map(function(nodo){
        if (nodo.id!=nodoId) {
            $("#listPeopleAvailable").append('<li onclick="addRelation(' + nodoId + ',this.value)" id="' + nodo.id + '" value="' + nodo.id + '">' + nodo.nombre + " Edad: " + nodo.edad + '</li>');
        }

    });
    console.log(personas[nodoId]);
}

function addRelation(nodoIdFrom,nodoIdTo){
    var nodoFrom = personas[nodoIdFrom];
    var nodoTo = personas[nodoIdTo];
    var relationName = $("#relationName")[0].value;
    var relation = {};
    relation.from = nodoIdFrom;
    relation.to = nodoIdTo;
    relation.name = relationName;
    relations.push(relation);
    $("#listRelations").append('<li >'+nodoFrom.nombre + "--["+relationName+"]-->" + nodoTo.nombre+'</li>');
    console.log(result);
}

function savePedigree() {
//            $.post( "api/pedigree", result, function( data ) {
//                console.log( data );
//            }, "json");
        console.log(JSON.stringify(result));
        $.ajax({
            url: 'api/pedigree',
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

     angular.module('pedigree', [])
       .controller('PedigreeController', ['$scope', function($scope) {
         $scope.nombre = '';
         $scope.edad = '';
       }]);

