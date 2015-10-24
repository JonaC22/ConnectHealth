$.put = function (url, data, callback, type) {

    if ($.isFunction(data)) {
        type = type || callback,
            callback = data,
            data = {}
    }

    return $.ajax({
        url: url,
        type: 'PUT',
        success: callback,
        data: data,
        contentType: type
    });
}

function error_catch(jqXHR, textStatus, errorThrown, cont) {
    var res = JSON.parse(jqXHR.responseText);

    if (res) {
        toggleLoading(false);
        var error_thrown = false;
        if (cont) error_thrown = cont(jqXHR, textStatus, errorThrown);
        if(!error_thrown){
            if(res.error.details){
                var err_msg = "ERROR: " + res.error.details + ". ";
                for(var campo in res.error.message) {
                    err_msg += res.error.message[campo] + ". ";
                }
                alert(err_msg);
                console.log(res);
            } else {
                if(res.error) {
                    alert("ERROR: " + res.error);
                    console.log(res.error);
                }
            }
        }
    }
    else {
        console.log(textStatus);
        console.log(errorThrown);
        toggleLoading(false);
        alert("Error: " + jqXHR.status + " " + errorThrown);
    }
}

function pedigree_not_selected(jqXHR, textStatus, errorThrown) {
    if(errorThrown == 'Not Found'){
        alert("Error: no hay un paciente seleccionado, por favor seleccione uno del listado.");
        window.location = '/pacientes.html';
        return true;
    }
    return false;
}

function showGailForm() {
    $("#calcularGailButton").hide();
    $("#gailForm").show();
}

function searchPerson() {
    var id = $("#searchPersonInput").val();
    if (id > 0) {
        window.location = "pedigree.html?id=" + id;
    }
}

function calculatePREMM126() {

    $("#calc_results").empty();
    $("#statsWidgets").hide();
    toggleLoading(true);

    $.getJSON("/api/model_calculator/premm126?patient_id=" + currentPatient.neo_id, function (data) {

        console.log(data);
        var result = $("#calc_results");
        if (data.status == "ERROR") {
            $("#statsWidgets").hide();
            result.append("ERROR: " + data.message);
        }
        else {
            var calc = data.model_calculator.calculations;
            var messages = data.model_calculator.messages;
            if (messages) {
                messages.forEach(function (msg) {
                    console.log(msg);
                    result.append(msg);
                });
            }
            $("#statsWidgets").show();
            $('#text_chart_group1').hide();
            $('#chart_group2').hide();
            $('#chart_group3').hide();
            $('#chart_group4').hide();
            $('#chart1').data('easyPieChart').update((calc.risk * 100));
            $('#perc1').text((calc.risk * 100).toFixed(2) + "%");
        }

        toggleLoading(false);
    }).fail(function(jqXHR, textStatus, errorThrown){
        error_catch(jqXHR, textStatus, errorThrown, false);
    });
}
function calculateGail() {

    $("#calc_results").empty();
    var menarcheAge = $("#gailMenarcheAge").val();
    var numberBiopsy = $("#gailBiopsies").val();
    $("#statsWidgets").hide();
    toggleLoading(true);
    $.getJSON("api/model_calculator/gail?patient_id=" + currentPatient.id + "&menarcheAge=" + menarcheAge + "&numberBiopsy=" + numberBiopsy, function (data) {

        console.log(data);
        var result = $("#calc_results");
        //DEPRECADO
        /*
         if (data.status == "ERROR") {
         $("#statsWidgets").hide();
         result.append("ERROR: " + data.message);
         }
         */
            var calc = data.model_calculator.calculations;
            $("#statsWidgets").show();
            $('#text_chart_group1').show();
            $('#chart_group2').show();
            $('#chart_group3').show();
            $('#chart_group4').show();
            //result.append("Riesgo absoluto de este paciente en 5 años: " + (data.absoluteRiskIn5Years * 100).toFixed(2) + "%");
            $('#chart1').data('easyPieChart').update((calc.absoluteRiskIn5Years * 100));
            $('#perc1').text((calc.absoluteRiskIn5Years * 100).toFixed(2) + "%");
            //result.append("<br>Riesgo promedio de una persona en 5 años: " + (calc.averageRiskIn5Years * 100).toFixed(2) + "%");
            $('#chart2').data('easyPieChart').update((calc.averageRiskIn5Years * 100));
            $('#perc2').text((calc.averageRiskIn5Years * 100).toFixed(2) + "%");
            //result.append("<br>Riesgo absoluto de este paciente hasta los 90 años: " + (calc.absoluteRiskAt90yo * 100).toFixed(2) + "%");
            $('#chart3').data('easyPieChart').update((calc.absoluteRiskAt90yo * 100));
            $('#perc3').text((calc.absoluteRiskAt90yo * 100).toFixed(2) + "%");
            //result.append("<br>Riesgo promedio de una persona hasta los 90 años: " + (calc.averageRiskAt90yo * 100).toFixed(2) + "%");
            $('#chart4').data('easyPieChart').update((calc.averageRiskAt90yo * 100));
            $('#perc4').text((calc.averageRiskAt90yo * 100).toFixed(2) + "%");


        toggleLoading(false);
    }).fail(function(jqXHR, textStatus, errorThrown){
        error_catch(jqXHR, textStatus, errorThrown, false);
    });

}


$.urlParam = function (name) {
    var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
    if (results == null) {
        return null;
    }
    else {
        return results[1] || 0;
    }
};
myDiagram = init("myDiagram");
diagramModal = init("diagramModal");

currentPatient = null;
newParent = null;
family = null;
toggleLoading(true);
$("#current_patient").hide();
function getPeopleNodesFromFamily(family) {
    var nodos = {};
    var people = [];

    $.each(family.patients, function (key, val) {
        nodos[val.neo_id] = val;
        val.attributes_go = [];
        for (var i = 0; i < val.patient_diseases.length; i++) {
            var enf = val.patient_diseases[i].disease.name;

            //TODO modificar por un checklist y agregar referencias (color - enfermedad)
            switch (enf) {
                case "cancer de ovario":
                    val.attributes_go.push("C");
                    break;
                case "cancer de mama":
                    val.attributes_go.push("L");
                    break;
                case "cancer colon rectal":
                    val.attributes_go.push("H");
                    break;
                case "cancer de endometrio":
                    val.attributes_go.push("F");
                    break;
                default:
                    val.attributes_go.push("E");
                    break;
            }
        }
    });

    $.each(family.relations, function (key, val) {
        if (val.name == "MADRE") {
            nodos[val.from].mother = val.to;
            if (nodos[val.from].father != undefined) {
                nodos[nodos[val.from].mother].husband = nodos[val.from].father;
                nodos[nodos[val.from].father].wife = nodos[val.from].mother;
            }
        } else if (val.name == "PADRE") {
            nodos[val.from].father = val.to;
            if (nodos[val.from].mother != undefined) {
                nodos[nodos[val.from].father].wife = nodos[val.from].mother;
                nodos[nodos[val.from].mother].husband = nodos[val.from].father;
            }
        }
    });

    $.each(nodos, function (key, val) {
        var p = {};
        //si es mayor de 90, tachar con una raya roja
        if (val.status == 'dead') {
            val.attributes_go.push("S");
            p.n = val.name + " " + val.lastname;
        }
        else {
            p.n = val.name + " " + val.lastname + ", edad: " + val.age;
        }

        p.key = val.neo_id;

        p.s = val.gender.toUpperCase();
        if (val.mother != undefined) p.m = val.mother;
        if (val.father != undefined) p.f = val.father;
        if (val.wife != undefined) p.ux = val.wife;
        if (val.husband != undefined) p.vir = val.husband;
        if (val.attributes_go != undefined) p.a = val.attributes_go;
        people.push(p);
    });

    console.log(people);
    return people;
}
$.getJSON("api/pedigrees/" + $.urlParam('id'), function (data) {

    family = data.pedigree;
    $("#pedigreeId").val(family.id);
    console.log(data);
    currentPatient = (data.pedigree.current);

    var people = getPeopleNodesFromFamily(family);
    setupDiagram(myDiagram, people, currentPatient.neo_id);

    myDiagram.addDiagramListener("ObjectSingleClicked",
        function (e) {
            var part = e.subject.part;
            var patient = get_patient_object(family.patients, part.data.key);
            if (!(part instanceof go.Link)) set_current_patient(patient);
        });

    toggleLoading(false);
    set_current_patient(currentPatient);
}).fail(function(jqXHR, textStatus, errorThrown){
        error_catch(jqXHR, textStatus, errorThrown, pedigree_not_selected);
});

function reloadDiagram() {
    var people = getPeopleNodesFromFamily(family);
    setupDiagram(myDiagram, people, currentPatient.neo_id);
}

function addNode(newPerson){
    family.patients.push(newPerson);
    console.log(family);
    reloadDiagram();
}

function addChild(parent, newChild) {
    family.patients.push(newChild);
    var newRelation = {
        "from": newChild.neo_id,
        "to": parent.neo_id,
        "name": parent.gender == "M" ? "PADRE" : "MADRE"
    };

    if (newParent !== undefined && newParent.gender == "M") {
        addFather(newChild, newParent);
    }
    if (newParent !== undefined && newParent.gender == "F") {
        addMother(newChild, newParent);
    }

    family.relations.push(newRelation);
    console.log(family);
    reloadDiagram();
}

function addMother(child, madre) {
    console.log("Agregando Madre");
    family.patients.push(madre);
    var newRelation = {
        "from": child.neo_id,
        "to": madre.neo_id,
        "name": "MADRE"
    };

    family.relations.push(newRelation);
    console.log(family);

//    if(newParent!== undefined && newParent.gender == "M"){
//        addFather(newParent);
//    }
    reloadDiagram();
}

function addFather(child, padre) {
    console.log("Agregando Padre");
    family.patients.push(padre);
    var newRelation = {
        "from": child.neo_id,
        "to": padre.neo_id,
        "name": "PADRE"
    };

    family.relations.push(newRelation);
    console.log(family);

//    if(newParent!== undefined && newParent.gender == "F"){
//        addMother(newParent);
//    }
    reloadDiagram();
}

function showCreateModal(type) {
    $("#patientForm")[0].reset();
    newParent = undefined;
    $("#typeRelationForm").val(type);
    switch (type) {
        case "NODE":
            $("#padreMadreSeleccionar").hide();
            $("input[type=radio]").attr('disabled', false);
            $("#modal-create-family-member").modal("show")
            break;
        case "CHILD":
            $("#padreMadreSeleccionar").show();
            $("#radio_gender").show();
            $("input[type=radio]").attr('disabled', false);
            $("#modal-create-family-member").modal("show")
            break;
        case "MOTHER":
            $("#padreMadreSeleccionar").hide();
            $('input:radio[name=gender]')[1].checked = true;
            $("#radio_gender").hide();
            $("#modal-create-family-member").modal("show")
            break;
        case "FATHER":
            $("#padreMadreSeleccionar").hide();
            $('input:radio[name=gender]')[0].checked = true;
            $("#radio_gender").hide();
            $("#modal-create-family-member").modal("show")
            break;
        case "DISEASE":
            var cont = function () {
                $("#modal-add-disease").modal("show");
            };
            selectDisease(cont);
            break;
        default:
            console.log('showCreateModal: incorrect case');
            break;
    }

}

function openDiagramModal() {
    var people = getPeopleNodesFromFamily(family);
    setupDiagram(diagramModal, people, null);

    var listener = function (e) {
        var part = e.subject.part;
        var patient = get_patient_object(family.patients, part.data.key);
        if (!(part instanceof go.Link)) {
            console.log("newParent", patient);
            if(patient.gender == currentPatient.gender){
                alert("Seleccione a otra persona del sexo contrario.")
                return;
            }else {
                newParent = patient;
                $("#otherParentLabel").text(newParent.name + " " + newParent.lastname);
                $("#modal-select-member").modal("hide")
                diagramModal.removeDiagramListener("ObjectSingleClicked",listener);
            }
        }
    };
       diagramModal.addDiagramListener("ObjectSingleClicked",listener);
    $("#modal-select-member").modal("show")
}

function selectDisease(cont) {
    toggleLoading(true);
    $.getJSON('/api/diseases', function (data) {
        console.log(data);

        var $select = $('#disease_id');
        $select.find('option').remove();
        $.each(data.diseases, function (key, value) {
            console.log(value);
            $select.append('<option value=' + value.id + '>' + value.name + '</option>');
        });
        toggleLoading(false);
        cont();
    }).fail(function(jqXHR, textStatus, errorThrown){
        error_catch(jqXHR, textStatus, errorThrown, false);
    });
}

function validate_disease() {

    var _id = $('#disease_id').val();
    var _age = $('#disease_age').val();
    var err_msg;

    if($.inArray(_id, ["2", "12", "22", "52"]) > -1 && currentPatient.gender == "M"){
        err_msg = "ERROR: la enfermedad solo afecta a pacientes de sexo femenino";
        $("#modal-add-disease").modal("hide");
        console.log(err_msg);
        alert(err_msg);
        return false;
    }

    if(_age > currentPatient.age){
        err_msg = "ERROR: edad de diagnostico es mayor a la edad del paciente";
        $("#modal-add-disease").modal("hide");
        console.log(err_msg);
        alert(err_msg);
        return false;
    }

    return true;
}

function createDisease() {

    var form = $("#addDiseaseForm");
    console.log(form.serialize());

    if(validate_disease()){
        $.put("/api/patients/" + currentPatient.id, form.serialize())
            .done(function (data) {
                console.log(data);
            })
            .fail(function(jqXHR, textStatus, errorThrown){
                error_catch(jqXHR, textStatus, errorThrown, false);
            });
    }

    updatePedigree();
    reloadDiagram();
    $("#modal-add-disease").modal("hide");
}

function _calculateAge(birthday) { // birthday is a date
    var ageDifMs = Date.now() - birthday.getTime();
    var ageDate = new Date(ageDifMs); // miliseconds from epoch
    return Math.abs(ageDate.getUTCFullYear() - 1970);
}

function validate_age(birth_date, rel_age, type_rel) {

    var bdate = birth_date.split("-");
    var f = new Date(bdate[0], bdate[1] - 1, bdate[2]);
    console.log(f);
    var age = _calculateAge(f);
    console.log(age, rel_age);

    switch (type_rel) {
        case "CHILD":
            return age < rel_age;
            break;
        case "MOTHER":
        case "FATHER":
            return age > rel_age;
            break;
        default:
            return true;
    }
}

function updatePedigree() {
    $.ajax({
        url: "/api/pedigrees/" + family.id,
        type: 'PUT',
        contentType: "application/json; charset=utf-8",
        data: JSON.stringify({"relations": family.relations}),
        dataType: "json"})
        .done(function (data) {
            console.log("Pedigree Updated");
            console.log(data);
        })
        .fail(function(jqXHR, textStatus, errorThrown){
            error_catch(jqXHR, textStatus, errorThrown, false);
        });
}

function createRelative() {
    console.log($("#patientForm").serialize());

    if(validate_age($("#birth_date").val(), currentPatient.age, $("#typeRelationForm").val())){
        $.post("/api/patients", $("#patientForm").serialize())
            .done(function (data) {
                console.log(data);
                switch ($("#typeRelationForm").val()) {
                    case "NODE":
                        addNode(data.patient);
                        break;
                    case "CHILD":
                        addChild(currentPatient, data.patient);
                        break;
                    case "MOTHER":
                        addMother(currentPatient, data.patient);
                        break;
                    case "FATHER":
                        addFather(currentPatient, data.patient);
                        break;
                }
                updatePedigree();
                $("#modal-create-family-member").modal("hide");
            })
            .fail(function(jqXHR, textStatus, errorThrown){
                error_catch(jqXHR, textStatus, errorThrown, false);
            });
    } else {
        var err_msg = "Error: edad del hijo es mayor que la del padre";
        console.log(err_msg);
        alert(err_msg);
    }

}

function set_current_patient(patient) {
    currentPatient = patient;

    if (patient.father == undefined)
        $("#agregarPadreButton").show();
    else
        $("#agregarPadreButton").hide();
    if (patient.mother == undefined)
        $("#agregarMadreButton").show();
    else
        $("#agregarMadreButton").hide();
    if (patient.id == family.current.id)
        $("#deletePersonButton").hide();
    else
        $("#deletePersonButton").show();


    var genderIcon=patient.gender=="M" ? '<i class="fa fa-male"></i> ' : '<i class="fa fa-female" style="color: pink;"></i> ';
    $("#currentPatientName").html(genderIcon+patient.name + " " + patient.lastname);
    $("#currentPatientAge").text(patient.age + " Años");
    $("#currentPatientStatus").text(patient.status);
//    $("#current_patient").text(patient.name + " " + patient.lastname + " edad: " + patient.age + " sexo: " + patient.gender + " id: " + patient.id);
//    $("#current_patient").show();
}

function get_patient_object(people, id) {
    var patient;
    $.each(people, function (key, val) {
//        console.log("patient", val);
        if (val.neo_id == id) patient = val;
    });

    return patient;
}

function deletePerson() {
    if (currentPatient.id == family.current.id) {
        alert("No se puede borrar al nodo Paciente");
        return;
    }
    toggleLoading(true);
    $.ajax({
        url: "/api/patients/" + currentPatient.id,
        type: 'DELETE',
        contentType: "application/json; charset=utf-8",
        dataType: "json"})
        .done(function (data) {
            console.log("Person Deleted");
            console.log(data);
            toggleLoading(false);
            var index = family.patients.indexOf(currentPatient);
            if (index > -1) {
                family.patients.splice(index, 1);
            }

            family.patients.forEach(function (pat) {
                    if (pat.wife == currentPatient.neo_id) pat.wife = undefined;
                    if (pat.husband == currentPatient.neo_id) pat.husband = undefined;
                    if (pat.father == currentPatient.neo_id) pat.father = undefined;
                    if (pat.mother == currentPatient.neo_id) pat.mother = undefined;
                }
            );
            var borrar = [];
            family.relations.forEach(function (rel) {
                if (rel.to == currentPatient.neo_id || rel.from == currentPatient.neo_id) {
                    borrar.push(rel)
                }
            });
            console.log("borrar", borrar);
            borrar.forEach(function (rel) {
                family.relations.splice(family.relations.indexOf(rel), 1);
            });
            console.log(family);
            set_current_patient(family.current);
            reloadDiagram();
        }).fail(function(jqXHR, textStatus, errorThrown){
            error_catch(jqXHR, textStatus, errorThrown, false);
        });
}

function showCreateRelationModal(type) {
    var people = getPeopleNodesFromFamily(family);
    setupDiagram(diagramModal, people, null);
    var callback;
    var listener = function (e) {
        var part = e.subject.part;
        var patient = get_patient_object(family.patients, part.data.key);
        if (!(part instanceof go.Link)) {
            console.log("newParent", patient);
            callback(patient);
        }
    };

    callback = function(patient){
        newParent = patient;
        $("#modal-select-member").modal("hide");
        switch (type){
            case "MOTHER":
                if (newParent !== undefined && newParent.gender == "F") {//TODO: add age validation
                    addMother(currentPatient, newParent);
                }
                break;
            case "FATHER":
                if (newParent !== undefined && newParent.gender == "M") {
                    addFather(currentPatient, newParent);
                }
                break;
        }
        updatePedigree();
        diagramModal.removeDiagramListener("ObjectSingleClicked", listener);
    };

    diagramModal.addDiagramListener("ObjectSingleClicked",listener);
    $("#modal-select-member").modal("show")
}
