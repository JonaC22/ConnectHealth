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
            var calc =  data.model_calculator.calculations;
            var messages = data.model_calculator.messages;
            if(messages){
                messages.forEach(function(msg){
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
        if (data.status == "ERROR") {
            $("#statsWidgets").hide();
            result.append("ERROR: " + data.message);
        }
        else {
            var calc =  data.model_calculator.calculations;
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
        }

        toggleLoading(false);
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

currentPatient=null;
newParent=null;
family=null;
toggleLoading(true);
$("#current_patient").hide();
function getPeopleNodesFromFamily(family) {
    var nodos = {};
    var people = [];

    $.each(family.patients, function (key, val) {
        nodos[val.neo_id] = val;
        val.attributes_go = [];
        for (var i = 0; i < val.patient_diseases.length; i++) {
            var enf = val.patient_diseases[i].name;

            switch (enf) {
                case "Cancer de Ovario":
                    val.attributes_go.push("B");
                    break;
                case "Cancer de Mama":
                    val.attributes_go.push("H");
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
});

function reloadDiagram() {
    var people = getPeopleNodesFromFamily(family);
    setupDiagram(myDiagram, people, currentPatient.neo_id);
}

function addChild(parent,newChild) {
    family.patients.push(newChild);
    var newRelation = {
        "from": newChild.neo_id,
        "to": parent.neo_id,
        "name": parent.gender == "M" ? "PADRE" : "MADRE"
    };

    if(newParent!== undefined && newParent.gender == "M"){
        addFather(newChild,newParent);
    }
    if(newParent!== undefined && newParent.gender == "F"){
        addMother(newChild,newParent);
    }

    family.relations.push(newRelation);
    console.log(family);
    reloadDiagram();
}

function addMother(child,madre) {
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

function addFather(child,padre) {
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
        case "CHILD":
            $("#padreMadreSeleccionar").show();
            $("#modal-create-family-member").modal("show")
            break;
        case "MOTHER":
            $("#padreMadreSeleccionar").hide();
            $('input:radio[name=gender]')[1].checked = true;
            $("#modal-create-family-member").modal("show")
            break;
        case "FATHER":
            $("#padreMadreSeleccionar").hide();
            $('input:radio[name=gender]')[0].checked = true;
            $("#modal-create-family-member").modal("show")
            break;
        case "DISEASE":
            var cont = function() {
                $("#modal-add-disease").modal("show");
            };
            selectDisease(cont);
        default:
            console.log('showCreateModal: incorrect case');
            break;
    }

}

function openDiagramModal(){
    var people = getPeopleNodesFromFamily(family);
    setupDiagram(diagramModal, people, null);
//    diagramModal.removeDiagramListener("ObjectSingleClicked");
    diagramModal.addDiagramListener("ObjectSingleClicked",
        function (e) {
            var part = e.subject.part;
            var patient = get_patient_object(family.patients, part.data.key);
            if (!(part instanceof go.Link)) {
                console.log("newParent",patient);
                newParent = patient;
                $("#otherParentLabel").text(newParent.name + " " + newParent.lastname);
                $("#modal-select-member").modal("hide")
            }
        });
    $("#modal-select-member").modal("show")
}

function selectDisease(cont) {
    toggleLoading(true);
    $.getJSON('/api/diseases', function(data){
        console.log(data);

        var $select = $('#select-enfermedad');
        $select.find('option').remove();
        $.each(data.diseases, function(key, value)
        {
            console.log(value);
            $select.append('<option value=' + value.id + '>' + value.name + '</option>');
        });
        toggleLoading(false);
        cont();
    });
}

function createDisease() {
    $("#joke").text('IMPLEMENTAME!!');
    $("#joke").css('color', 'red');
    console.log($("#addDiseaseForm").serialize());
}

function createRelative() {
    console.log($("#patientForm").serialize());
    $.post("/api/patients", $("#patientForm").serialize())
        .done(function (data) {
            console.log(data);
            switch ($("#typeRelationForm").val()) {
                case "CHILD":
                    addChild(currentPatient,data.patient);
                    break;
                case "MOTHER":
                    addMother(currentPatient,data.patient);
                    break;
                case "FATHER":
                    addFather(currentPatient,data.patient);
                    break;
            }
            $.ajax({
                url: "/api/pedigrees/" + family.id,
                type: 'PUT',
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify({"relations": family.relations}),
                dataType: "json"})
                .done(function (data) {
                    console.log("Pedigree Updated");
                    console.log(data);
                });
            $("#modal-create-family-member").modal("hide");
        });
}

function set_current_patient(patient) {
    currentPatient = patient;
    $("#current_patient").text(patient.name + " " + patient.lastname + " edad: " + patient.age + " sexo: " + patient.gender + " id: " + patient.id);
    $("#current_patient").show();
}

function get_patient_object(people, id) {
    var patient;
    $.each(people, function (key, val) {
//        console.log("patient", val);
        if (val.neo_id == id) patient = val;
    });

    return patient;
}