function showGailForm() {
    $("#calcularGailButton").hide();
    $("#gailForm").show();
}

function calculateGail() {
//    $("#gailForm").hide();
//    $("#calcularGailButton").show();
    $("#gailResults").empty();
    var menarcheAge = $("#gailMenarcheAge").val();
    var numberBiopsy = $("#gailBiopsies").val();

    toggleLoading(true);
    $.getJSON("api/pedigree/gailModelCalculate?id=" + currentPatient.id + "&menarcheAge=" + menarcheAge + "&numberBiopsy=" + numberBiopsy, function (data) {

        console.log(data);
        $("#statsWidgets").show();
        var result = $("#gailResults");
        if (data.status == "ERROR")
            result.append("ERROR: " + data.message);
        else {
            result.append("Riesgo absoluto de este paciente en 5 años: " + (data.absoluteRiskIn5Years * 100).toFixed(2) + "%");
            $('#chart1').data('easyPieChart').update((data.absoluteRiskIn5Years * 100));
            result.append("<br>Riesgo promedio de una persona en 5 años: " + (data.averageRiskIn5Years * 100).toFixed(2) + "%");
            $('#chart2').data('easyPieChart').update((data.averageRiskIn5Years * 100));
            result.append("<br>Riesgo absoluto de este paciente hasta los 90 años: " + (data.absoluteRiskAt90yo * 100).toFixed(2) + "%");
            $('#chart3').data('easyPieChart').update((data.absoluteRiskAt90yo * 100));
            result.append("<br>Riesgo promedio de una persona hasta los 90 años: " + (data.averageRiskAt90yo * 100).toFixed(2) + "%");
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
var familia;

toggleLoading(true);
$("#current_patient").hide();
$.getJSON("api/pedigree?id=" + $.urlParam('id'), function (data) {

    var family = data;
    console.log(data);
    var nodos = {};
    var people = [];

    currentPatient = data.current;

    $.each(data.people, function (key, val) {
        nodos[val.id] = val;
        val.attributes_go = [];
        for (var i = 0; i < val.diseases.length; i++) {
            var enf = val.diseases[i].nombre;

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

    $.each(data.relations, function (key, val) {
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
        if (val.age > 90) {
            val.attributes_go.push("S");
            p.n = val.name + " " + val.surname;
        }
        else {
            p.n = val.name + " " + val.surname + ", edad: " + val.age;
        }

        p.key = val.id;

        p.s = val.gender.toUpperCase();
        if (val.mother != undefined) p.m = val.mother;
        if (val.father != undefined) p.f = val.father;
        if (val.wife != undefined) p.ux = val.wife;
        if (val.husband != undefined) p.vir = val.husband;
        if (val.attributes_go != undefined) p.a = val.attributes_go;
        people.push(p);
    });

//        people.push( { key: 999, n: "abuela", s: "F", a: ["B","H", "L"] });
    console.log(people);

    setupDiagram(myDiagram, people, null);

    myDiagram.addDiagramListener("ObjectSingleClicked",
        function (e) {
            var part = e.subject.part;
            var patient = get_patient_object(family.people, part.data.key);
            if (!(part instanceof go.Link)) set_current_patient(patient);
        });

    toggleLoading(false);
    set_current_patient(currentPatient);
});

function set_current_patient(patient) {
    currentPatient = patient;
    $("#current_patient").text(patient.name + " " + patient.surname + " edad: " + patient.age + " sexo: " + patient.gender + " id: " + patient.id);
    $("#current_patient").show();
}

function get_patient_object(people, id) {
    console.log("people", people);
    var patient;
    $.each(people, function (key, val) {
        console.log("patient", val);
        if (val.id == id) patient = val;
    });

    return patient;
}