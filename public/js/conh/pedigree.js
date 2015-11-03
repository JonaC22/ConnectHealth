function pedigree_not_selected(jqXHR, textStatus, errorThrown) {
    if (errorThrown == 'Not Found') {
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
    }).fail(function (jqXHR, textStatus, errorThrown) {
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
    }).fail(function (jqXHR, textStatus, errorThrown) {
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
diseases = [];
currentPatient = null;
newParent = null;
family = null;
toggleLoading(true);
$("#current_patient").hide();

function getPeopleNodesFromFamily(family) {
    var nodos = {};
    var people = [];
    var diseaseUnchecked = $("#enfermedadesCheckbox input:checkbox:not(:checked)").map(function () {
        return $(this).val();
    });
    var diseasesTemp = [];

    $.each(family.patients, function (key, val) {
        for (var i = 0; i < val.patient_diseases.length; i++) {
            var enf = val.patient_diseases[i].disease.name;
            diseasesTemp.push(enf);
        }
    });

    var diseases = _.uniq(diseasesTemp);
    console.log(diseases);
    loadCheckbox(diseases);

    $.each(family.patients, function (key, val) {
        nodos[val.neo_id] = val;
        val.attributes_go = [];
        val.wife=undefined;
        val.husband=undefined;
        val.mother=undefined;
        val.father=undefined;

        for (var i = 0; i < val.patient_diseases.length; i++) {
            var enf = val.patient_diseases[i].disease.name;
            if (jQuery.inArray(enf, diseaseUnchecked) !== -1) {
                continue;
            }
            var color_id = find_reference(enf);
            switch (color_id) {
                case 1:
                    val.attributes_go.push("C");
                    break;
                case 2:
                    val.attributes_go.push("J");
                    break;
                case 3:
                    val.attributes_go.push("G");
                    break;
                case 4:
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
        //si esta muerto, tachar con una raya roja
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
}).fail(function (jqXHR, textStatus, errorThrown) {
    error_catch(jqXHR, textStatus, errorThrown, pedigree_not_selected);
});

function reloadDiagram() {
    clear_references();
    redraw();
}

function redraw(){
    var people = getPeopleNodesFromFamily(family);
    setupDiagram(myDiagram, people, currentPatient.neo_id);
}

function addNode(newPerson) {
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
    if (child.age >= madre.age) {
        alert("Error de Validación de edad");
        return
    }

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
    if (child.age >= padre.age) {
        alert("Error de Validación de edad");
        return
    }
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
    $("#createButton").show();
    $("#editButton").hide();
    $("#diagnosticos").hide();
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
            if (patient.gender == currentPatient.gender) {
                alert("Seleccione a otra persona del sexo contrario.")
                return;
            } else {
                newParent = patient;
                $("#otherParentLabel").text(newParent.name + " " + newParent.lastname);
                $("#modal-select-member").modal("hide")
                diagramModal.removeDiagramListener("ObjectSingleClicked", listener);
            }
        }
    };
    diagramModal.addDiagramListener("ObjectSingleClicked", listener);
    $("#modal-select-member").modal("show")
}

function selectDisease(cont) {
    toggleLoading(true);
    $.getJSON('/api/diseases', function (data) {
        console.log(data);
        diseases_data = data;
        var $select = $('#disease_id');
        $select.find('option').remove();
        $.each(data.diseases, function (key, value) {
            console.log(value);
            $select.append('<option value=' + value.id + '>' + value.name + '</option>');
        });
        toggleLoading(false);
        cont();
    }).fail(function (jqXHR, textStatus, errorThrown) {
        error_catch(jqXHR, textStatus, errorThrown, false);
    });
}

function validate_disease() {

    var _id = $('#disease_id').val();
    var _age = $('#disease_age').val();
    var _gender = currentPatient.gender;
    var _disease_gender;
    var err_msg;
    var wrong_gender = false;

    var _collection = diseases_data.diseases;

    $.each(_collection, function(dis) {
            console.log(_collection[dis].id, _id);
            if (_collection[dis].id == _id) {
                _disease_gender = _collection[dis].gender;
            }
        }
    );

    if (_disease_gender == "F" && _gender == "M") {
        err_msg = "ERROR: la enfermedad solo afecta a pacientes de sexo femenino";
        wrong_gender = true;
    }

    if (_disease_gender == "M" && _gender == "F") {
        err_msg = "ERROR: la enfermedad solo afecta a pacientes de sexo masculino";
        wrong_gender = true;
    }

    if (wrong_gender){
        $("#modal-add-disease").modal("hide");
        console.log(err_msg);
        alert(err_msg);
        return false;
    }

    if (_age > currentPatient.age) {
        err_msg = "ERROR: edad de diagnostico es mayor a la edad del paciente";
        $("#modal-add-disease").modal("hide");
        console.log(err_msg);
        alert(err_msg);
        return false;
    }

    return true;
}

function validate_gender_change(){
    var _gender = $('input[name="gender"]:checked').val();
    var _diseases = currentPatient.patient_diseases;
    var _diseases_genders = [];
    var err_msg;
    $.each(_diseases, function(i){
        _diseases_genders.push(_diseases[i].disease.gender);
    });
    _diseases_genders = _.uniq(_diseases_genders);
    if(_.contains(_diseases_genders, 'F') && _gender == 'M') err_msg = 'ERROR: el paciente padece una enfermedad valida solamente para sexo femenino';
    if(_.contains(_diseases_genders, 'M') && _gender == 'F') err_msg = 'ERROR: el paciente padece una enfermedad valida solamente para sexo masculino';
    if(err_msg){
        console.log(err_msg);
        alert(err_msg);
        return false;
    }
    return true;
}

function createDisease() {

    var form = $("#addDiseaseForm");
    console.log(form.serialize());
    if (validate_disease()) {
        toggleLoading(true);
        var patient = currentPatient;
        $.put("/api/patients/" + currentPatient.id, form.serialize())
            .done(function (data) {
                console.log(data);
                patient.patient_diseases = data.patient.patient_diseases;
                reloadDiagram();
                toggleLoading(false);
            })
            .fail(function (jqXHR, textStatus, errorThrown) {
                error_catch(jqXHR, textStatus, errorThrown, false);
            });
    }

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
    var age = _calculateAge(f);
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
        .fail(function (jqXHR, textStatus, errorThrown) {
            error_catch(jqXHR, textStatus, errorThrown, false);
        });
}

function createRelative() {
    console.log($("#patientForm").serialize());
    toggleLoading(true);
    $("#modal-create-family-member").modal("hide");
    if (validate_age($("#birth_date").val(), currentPatient.age, $("#typeRelationForm").val())) {
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
                toggleLoading(false);
            })
            .fail(function (jqXHR, textStatus, errorThrown) {
                error_catch(jqXHR, textStatus, errorThrown, false);
                $("#modal-create-family-member").modal("show");
            });
    } else {
        var err_msg = "Error: edad del hijo es mayor que la del padre";
        console.log(err_msg);
        alert(err_msg);
    }

}

function set_current_patient(patient) {
    currentPatient = patient;

    if (patient.father == undefined) {
        $("#agregarPadreButton").show();
        $("#agregarRelacionPadreButton").show();
    }
    else {
        $("#agregarPadreButton").hide();
        $("#agregarRelacionPadreButton").hide();
    }
    if (patient.mother == undefined) {
        $("#agregarMadreButton").show();
        $("#agregarRelacionMadreButton").show();
    } else {
        $("#agregarMadreButton").hide();
        $("#agregarRelacionMadreButton").hide();
    }
    if (patient.id == family.current.id) {
        $("#deletePersonButton").hide();
    }
    else {
        $("#deletePersonButton").show();
    }


    var genderIcon = patient.gender == "M" ? '<i class="fa fa-male"></i> ' : '<i class="fa fa-female" style="color: pink;"></i> ';
    $("#currentPatientName").html(genderIcon + patient.name + " " + patient.lastname);
    if (patient.status != "dead")
        $("#currentPatientAge").text(patient.age + " Años");
    else
        $("#currentPatientAge").text("");
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

function checkDelete() {
    if (confirm("¿Está seguro que quiere borrar la persona?")) {
        deletePerson()
    }
}

function removeFromArray(array, item) {
    var index = array.indexOf(item);
    if (index > -1) {
        array.splice(index, 1);
    }
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
            removeFromArray(family.patients, currentPatient);
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
        }).fail(function (jqXHR, textStatus, errorThrown) {
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

    callback = function (patient) {
        newParent = patient;
        $("#modal-select-member").modal("hide");
        switch (type) {
            case "MOTHER":
                if (newParent !== undefined && newParent.gender == "F") {
                    addMother(currentPatient, newParent);
                } else {
                    alert("Error en la creación");
                }
                break;
            case "FATHER":
                if (newParent !== undefined && newParent.gender == "M") {
                    addFather(currentPatient, newParent);
                } else {
                    alert("Error en la creación");
                }
                break;
        }
        updatePedigree();
        diagramModal.removeDiagramListener("ObjectSingleClicked", listener);
    };

    diagramModal.addDiagramListener("ObjectSingleClicked", listener);
    $("#modal-select-member").modal("show")
}

function loadCheckbox(diseases) {
    var count = 1;
    var total = 1;
    var diseaseUnchecked = $("#enfermedadesCheckbox input:checkbox:not(:checked)").map(function () {
        return $(this).val();
    });
    $("#enfermedadesCheckbox").empty();
    console.log(diseases);
    $.each(diseases, function (key, val) {
        var checked = (jQuery.inArray(val, diseaseUnchecked) !== -1 || count > 4) ? "" : "checked";
        var color;
        if(checked == "checked"){
            if(!find_reference(val)) update_references(val, true);
            count++;
        }
        var tag_id = 'check_'+total;
        var color_id = find_reference(val);
        console.log(checked_diseases, diseases_colors[color_id]);
        $("#enfermedadesCheckbox").append('<input id="'+tag_id+'" onclick="disease_checked_change(this)" name="diseaseCheck" type="checkbox" style="margin:14px;" value="' + val + '" ' + checked + '>'+ val +'<span id="color_'+tag_id+'" style="margin-left: 5px; padding-left: 15px; background-color: '+ diseases_colors[color_id] +';"></span>');
        total++;
    });
}

function showEditDiseases() {
    $("#diagnosticos").empty();
    $("#diagnosticos").append('<label>Diagnósticos</label>');
    $.each(currentPatient.patient_diseases, function (key, value) {

        $("#diagnosticos").append('<div class="alert alert-danger">' +
            '            <button type="button" class="close" onclick="deleteDisease(' + key + ')"><i class="fa fa-times"></i></button>' +
            '        <i class="fa fa-ban-circle"></i><strong>' + value.disease.name + ' a los ' + value.age + ' años</strong>' +
            '        </div>');
    });
}

function deleteDisease(key) {
    var disease = currentPatient.patient_diseases[key];
    var params = {};
    params.disease_id = disease.disease.id;
    params.disease_name = disease.disease.name;
    params.disease_age = disease.age;
    params.disease_method = "remove";
    console.log(params);
    $.put("/api/patients/" + currentPatient.id, params)
        .done(function (data) {
            console.log(data);
            currentPatient.patient_diseases = data.patient.patient_diseases;
            reloadDiagram();
            showEditDiseases();
        })
        .fail(function (jqXHR, textStatus, errorThrown) {
            error_catch(jqXHR, textStatus, errorThrown, false);
        });
}

function showEditPerson() {
    toggleLoading(false);
    $("#patientForm")[0].reset();
    $("#createButton").hide();
    $("#editButton").show();
    $("#diagnosticos").show();
    $("#modal-create-family-member").modal("show");
    $.each(currentPatient, function (key, value) {
        if (key != "gender") {
            $("#patientForm").find("input[name='" + key + "']").val(value);
        }
    });
    showEditDiseases();
    if (currentPatient.gender == "M") {
        $('input:radio[name=gender]')[0].checked = true;
    } else {
        $('input:radio[name=gender]')[1].checked = true;
    }
    var id = currentPatient;
}

function editPatient() {
    console.log($("#patientForm").serialize());
    $("#modal-create-family-member").modal("hide");
    if(validate_gender_change()){
        toggleLoading(true);
        $.put("/api/patients/" + currentPatient.id, $("#patientForm").serialize())
            .done(function (data) {
                toggleLoading(false);
                console.log(data);
                removeFromArray(family.patients, currentPatient);
                currentPatient = data.patient;
                family.patients.push(currentPatient);
                reloadDiagram();
            }).fail(function (jqXHR, textStatus, errorThrown) {
                error_catch(jqXHR, textStatus, errorThrown, false);
            });
    }
}

function loadDeleteRelations() {
    $("#relations").empty();
    $.each(family.relations, function (key, val) {
        if (val.to == currentPatient.neo_id) {//relacion hijos
            var hijo = get_patient_object(family.patients, val.from);
            var parentezco = currentPatient.gender == "M" ? "Padre" : "Madre";
            $("#relations").append('<div class="alert alert-danger">' +
                '            <button type="button" class="close" onclick="deleteRelation(' + key + ')"><i class="fa fa-times"></i></button>' +
                '        <i class="fa fa-ban-circle"></i><strong>' + parentezco + ' de ' + hijo.name + " " + hijo.lastname + '</strong>' +
                '        </div>');
        } else if (val.from == currentPatient.neo_id) {//relacion madre o padre
            var padre = get_patient_object(family.patients, val.to);
            var parentezco = currentPatient.gender == "M" ? "Hijo" : "Hija";
            $("#relations").append('<div class="alert alert-danger">' +
                '            <button type="button" class="close" onclick="deleteRelation(' + key + ')"><i class="fa fa-times"></i></button>' +
                '        <i class="fa fa-ban-circle"></i><strong>' + parentezco + ' de ' + padre.name + " " + padre.lastname + '</strong>' +
                '        </div>');
        }
    });
    if ($('#relations').is(':empty')) {
        $("#modal-remove-relations").modal("hide");
    }
}

function deleteRelation(id){
    family.relations.splice(id,1);
    updatePedigree();
    loadDeleteRelations();
    reloadDiagram();
}

function showDeleteRelations() {
//    var people = getPeopleCloseNodesFromFamily(family);
//    setupDiagram(diagramModal, people, null);
//    var callback;
//    var listener = function (e) {
//        var part = e.subject.part;
//        console.log(part)
////        var relation = get_patient_object(family.patients, part.data.key);
//        if ((part instanceof go.Link)) {
//            console.log("relation", part);
//            callback(part);
//        }
//    };
//
//    callback = function (patient) {
//        $("#modal-select-member").modal("hide");
////        updatePedigree();
//        diagramModal.removeDiagramListener("ObjectSingleClicked", listener);
//    };
//
//    diagramModal.addDiagramListener("ObjectSingleClicked", listener);
//    $("#modal-select-member").modal("show")
    $("#modal-remove-relations").modal("show");
    loadDeleteRelations();
}

function getPeopleCloseNodesFromFamily(family) {
    family = jQuery.extend(true, {}, family);
    var nodos = {};
    var people = [];
    var validIds = [];
    validIds[currentPatient.neo_id] = true;
    $.each(family.relations, function (key, val) {
        if (val.to == currentPatient.neo_id) {
            validIds[val.from] = true
        } else if (val.from == currentPatient.neo_id) {
            validIds[val.to] = true
        }
    });

    $.each(family.patients, function (key, val) {
        if (validIds[val.neo_id]!=undefined) {
            nodos[val.neo_id] = val;
            val.attributes_go = [];
            val.wife=undefined;
            val.husband=undefined;
            val.mother=undefined;
            val.father=undefined;
        }
    });
    $.each(family.relations, function (key, val) {
        if (val.to != currentPatient.neo_id && val.from != currentPatient.neo_id) {
            return;
        }
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

function disease_checked_change(input){
    if($("#enfermedadesCheckbox input:checkbox:checked").length > 4){
        input.checked = false;
        alert("Solo pueden mostrarse 4 enfermedades simultaneamente.");
    }
    else{
        update_references(input.value, input.checked);
        redraw();
        toggle_checkbox_color(input);
    }
}

function toggle_checkbox_color(input){
    var checked = input.checked;
    if(checked) add_color_checkbox(input);
    else remove_color_checkbox(input);
}

function add_color_checkbox(input){
    var color_id = find_reference(input.value);
    document.getElementById('color_'+input.id).style.backgroundColor = diseases_colors[color_id];
}

function remove_color_checkbox(input){
    document.getElementById('color_'+input.id).style.backgroundColor = 'none';
}

//enum de enfermedad-color
var diseases_colors = {1: 'red', 2: '#00FF00', 3: 'blue', 4: 'yellow'};
var checked_diseases = {1: null, 2: null, 3: null, 4: null};
var diseases_data;

function update_references(name, checked){
    for(var i = 1; i < 5; i++){
        if(checked_diseases[i] == null && checked){
            checked_diseases[i] = name;
            return;
        }
        if(checked_diseases[i] == name && !checked){
            checked_diseases[i] = null;
            return;
        }
    }
}

function find_reference(name){
    for(var i = 1; i < 5; i++){
        if(checked_diseases[i] == name){
            return i;
        }
    }
}

function clear_references(){
    for(var i = 1; i < 5; i++){
        checked_diseases[i] = null;
    }
}