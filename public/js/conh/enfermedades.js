var PubMedDataSource = function (options) {
    this._formatter = options.formatter;
    this._columns = options.columns;
    this._resultsId = options.resultsId
};

PubMedDataSource.prototype = {

    /**
     * Returns stored column metadata
     */
    columns: function () {
        return this._columns;
    },

    /**
     * Called when Datagrid needs data. Logic should check the options parameter
     * to determine what data to return, then return data by calling the callback.
     * @param {object} options Options selected in datagrid (ex: {pageIndex:0,pageSize:5,search:'searchterm'})
     * @param {function} callback To be called with the requested data.
     */
    data: function (options, callback) {
        var self = this;
        var start = options.pageSize * options.pageIndex;
        var pagesize = options.pageSize;
        var pageIndex = options.pageIndex;

        // Prepare data to return to Datagrid
        var count = self._resultsId.length;
        var startIndex = start;
        var endIndex = startIndex + pagesize;
        var end = (endIndex > count) ? count : endIndex;
        var pages = Math.ceil(count / pagesize);
        var page = pageIndex + 1;
        // Allow client code to format the data
        if (self._formatter) self._formatter(self._resultsId);
        // Return data to Datagrid
        callback({ data: self._resultsId, start: startIndex, end: end, count: count, pages: pages, page: page });
    }
};

function replace_affected_genders(data){
    console.log(data);
    data.forEach(function(d){
        switch(d.gender){
            case 'F':
                d.gender = 'Solo femenino';
                break;
            case 'M':
                d.gender = 'Solo masculino';
                break;
            case 'B':
                d.gender = 'Ambos';
                break;
        }
    });

    return data;
}

function search() {
    toggleLoading(true);

    $.getJSON('/api/diseases', {}, function (data) {

        console.log(data);
        var ids = replace_affected_genders(data.diseases);
        console.log(ids);

        $('#GridEnfermedades').each(function () {
            $(this).datagrid({
                dataSource: new PubMedDataSource({
                    // Column definitions for Datagrid
                    columns: [
                        {
                            property: 'name',
                            label: 'Nombre',
                            sortable: true
                        },
                        {
                            property: 'gender',
                            label: 'Sexos afectados',
                            sortable: true
                        },
                        {
                            property: 'edit',
                            label: 'Editar',
                            sortable: false
                        },
                        {
                            property: 'delete',
                            label: 'Borrar',
                            sortable: false
                        }
                    ],

                    resultsId: ids,
                    // Create IMG tag for each returned image
                    formatter: function (items) {
                        $.each(items, function (index, item) {
                            item.edit = '<a onclick="showEditDisease(' + item.id + ')"><i class="fa fa-pencil"></i></a>';
                            item.delete = '<a onclick="showDeleteDisease(' + item.id + ')"><i class="fa fa-trash-o"></i></a>';
                        });
                    }
                })
            });
        });
        toggleLoading(false);
    }).fail(function (jqXHR, textStatus, errorThrown) {
        console.log(textStatus);
        console.log(errorThrown);
        toggleLoading(false);
        alert("Error: " + jqXHR.status + " " + errorThrown);
    });

}

function showEditDisease() {
    toggleLoading(true);
    $.getJSON("/api/diseases/" + currentPatient.id, function (data) {
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

function showDeleteDisease(id) {
    if (confirm('¿Estás seguro que quieres borrar esta enfermedad?')) {
        toggleLoading(true);
        $.delete("/api/diseases/" + id)
            .done(function (data) {
                toggleLoading(false);
                $('#MyStretchGrid').datagrid('reload');
                console.log(data);
            }).fail(function (jqXHR, textStatus, errorThrown) {
                error_catch(jqXHR, textStatus, errorThrown, false);
            });
    }
}

function createDisease(){
    console.log( $("#diseaseForm" ).serialize());
    $.post("/api/diseases", $( "#diseaseForm" ).serialize())
        .done(function(data){
            console.log(data);
            $('#GridEnfermedades').datagrid('reload');
            $("#modal-form").modal("hide")
//            search();
        })
        .fail(function (jqXHR, textStatus, errorThrown) {
            error_catch(jqXHR, textStatus, errorThrown, false);
        });
}

search();