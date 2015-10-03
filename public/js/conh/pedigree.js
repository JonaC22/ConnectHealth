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

    var v1 = $("#v1").val();
    var v2 = $("#v2").val();
    var v3 = $("#v3").val();
    var v4 = $("#v4").val();
    var v5 = $("#v5").val();
    var v6 = $("#v6").val();
    var v7 = $("#v7").val();
    var v8 = $("#v8").val();
    var v9 = $("#v9").val();
    $("#calc_results").empty();
    $("#statsWidgets").hide();
    toggleLoading(true);

    $.getJSON("/api/model_calculator/premm126?patient_id=" + currentPatient.id + "&v1=" + v1 + "&v2=" + v2 + "&v3=" + v3 + "&v4=" + v4 + "&v5=" + v5 + "&v6=" + v6 + "&v7=" + v7 + "&v8=" + v8 + "&v9=" + v9, function (data) {

        console.log(data);
        var result = $("#calc_results");
        if (data.status == "ERROR") {
            $("#statsWidgets").hide();
            result.append("ERROR: " + data.message);
        }
        else {
            $("#statsWidgets").show();
            $('#text_chart_group1').hide();
            $('#chart_group2').hide();
            $('#chart_group3').hide();
            $('#chart_group4').hide();
            $('#chart1').data('easyPieChart').update((data.results * 100));
            $('#perc1').text((data.results * 100).toFixed(2) + "%");
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
    $.getJSON("api/pedigree/query?type=table&model=gail&id=" + currentPatient.id + "&menarcheAge=" + menarcheAge + "&numberBiopsy=" + numberBiopsy, function (data) {

        console.log(data);

        var result = $("#calc_results");
        if (data.status == "ERROR") {
            $("#statsWidgets").hide();
            result.append("ERROR: " + data.message);
        }
        else {
            $("#statsWidgets").show();
            $('#text_chart_group1').show();
            $('#chart_group2').show();
            $('#chart_group3').show();
            $('#chart_group4').show();
            //result.append("Riesgo absoluto de este paciente en 5 años: " + (data.absoluteRiskIn5Years * 100).toFixed(2) + "%");
            $('#chart1').data('easyPieChart').update((data.absoluteRiskIn5Years * 100));
            $('#perc1').text((data.absoluteRiskIn5Years * 100).toFixed(2) + "%");
            //result.append("<br>Riesgo promedio de una persona en 5 años: " + (data.averageRiskIn5Years * 100).toFixed(2) + "%");
            $('#chart2').data('easyPieChart').update((data.averageRiskIn5Years * 100));
            $('#perc2').text((data.averageRiskIn5Years * 100).toFixed(2) + "%");
            //result.append("<br>Riesgo absoluto de este paciente hasta los 90 años: " + (data.absoluteRiskAt90yo * 100).toFixed(2) + "%");
            $('#chart3').data('easyPieChart').update((data.absoluteRiskAt90yo * 100));
            $('#perc3').text((data.absoluteRiskAt90yo * 100).toFixed(2) + "%");
            //result.append("<br>Riesgo promedio de una persona hasta los 90 años: " + (data.averageRiskAt90yo * 100).toFixed(2) + "%");
            $('#chart4').data('easyPieChart').update((data.averageRiskAt90yo * 100));
            $('#perc4').text((data.averageRiskAt90yo * 100).toFixed(2) + "%");
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
init();
var currentPatient;
var family;
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

function addChild(newChild) {
    family.patients.push(newChild);
    var newRelation = {
        "from": newChild.neo_id,
        "to": currentPatient.neo_id,
        "name": currentPatient.gender == "M" ? "PADRE" : "MADRE"
    };

    family.relations.push(newRelation);
    console.log(family);
    reloadDiagram();
}

function addMother(madre) {
    family.patients.push(madre);
    var newRelation = {
        "from": currentPatient.neo_id,
        "to": madre.neo_id,
        "name": "MADRE"
    };

    family.relations.push(newRelation);
    console.log(family);
    reloadDiagram();
}

function addFather(padre) {
    family.patients.push(padre);
    var newRelation = {
        "from": currentPatient.neo_id,
        "to": padre.neo_id,
        "name": "PADRE"
    };

    family.relations.push(newRelation);
    console.log(family);
    reloadDiagram();
}

function showCreateModal(type) {
    $("#patientForm")[0].reset();
    $("#typeRelationForm").val(type);
    switch (type) {
        case "CHILD":
            break;
        case "MOTHER":
            break;
        case "FATHER":
            break;
    }
    $("#modal-create-family-member").modal("show")
}

function createRelative() {
    console.log($("#patientForm").serialize());
    $.post("/api/patients", $("#patientForm").serialize())
        .done(function (data) {
            console.log(data);
            switch ($("#typeRelationForm").val()) {
                case "CHILD":
                    addChild(data.patient);
                    break;
                case "MOTHER":
                    addMother(data.patient);
                    break;
                case "FATHER":
                    addFather(data.patient);
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
        console.log("patient", val);
        if (val.neo_id == id) patient = val;
    });

    return patient;
}