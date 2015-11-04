function showCreateModal() {
    $("#patientForm")[0].reset();
    $("#createButton").show();
    $("#editButton").hide();
    $("#modal-form").modal("show");
}


function createPatient() {
    console.log($("#patientForm").serialize());
    $("#modal-form").modal("hide");
    toggleLoading(true);
    $.post("/api/patients", $("#patientForm").serialize())
        .done(function (data) {
            toggleLoading(false);
            console.log(data);
            $('#MyStretchGrid').datagrid('reload');
            $("#modal-form").modal("hide");
        }).fail(function (jqXHR, textStatus, errorThrown) {
            error_catch(jqXHR, textStatus, errorThrown, false);
        });
}

function editPatient(id) {
    console.log($("#patientForm").serialize());
    $("#modal-form").modal("hide");
    toggleLoading(true);
    $.put("/api/patients/"+id, $("#patientForm").serialize())
        .done(function (data) {
            toggleLoading(false);
            console.log(data);
            $('#MyStretchGrid').datagrid('reload');
            $("#modal-form").modal("hide");
        }).fail(function (jqXHR, textStatus, errorThrown) {
            error_catch(jqXHR, textStatus, errorThrown, false);
        });
}

function showEditPatient(id) {
    toggleLoading(true);
    $.getJSON("/api/patients/" + id, function (data) {
        console.log(data);
        toggleLoading(false);
        $("#patientForm")[0].reset();
        $("#createButton").hide();
        $("#editButton").show();
        $("#modal-form").modal("show");
        $.each(data.patient, function (key, value) {
            if (key != "gender") {
                $("#patientForm").find("input[name='" + key + "']").val(value);
            }
        });
        if (data.patient.gender == "M") {
            $('input:radio[name=gender]')[0].checked = true;
        } else {
            $('input:radio[name=gender]')[1].checked = true;
        }
        $("#editButton").click(function(){
            editPatient(id)
        });
    });
}

function showDeletePatient(id) {
    if (confirm('¿Estás seguro que quieres borrar este paciente?')) {
        toggleLoading(true);
        $.delete("/api/patients/" + id)
            .done(function (data) {
                toggleLoading(false);
                $('#MyStretchGrid').datagrid('reload');
                console.log(data);
            }).fail(function (jqXHR, textStatus, errorThrown) {
                error_catch(jqXHR, textStatus, errorThrown, false);
            });
    }
}
