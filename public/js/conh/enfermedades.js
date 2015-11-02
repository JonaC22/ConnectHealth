var EnfermedadesDataSource = function (options) {
    this._formatter = options.formatter;
    this._columns = options.columns;
    this._resultsId = options.resultsId
};

EnfermedadesDataSource.prototype = {

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
    console.log(html_enfermedades);
    $('#datagridEnfermedades').html(html_enfermedades);
    $.getJSON('/api/diseases', {}, function (data) {

        console.log(data);
        var ids = replace_affected_genders(data.diseases);
        console.log(ids);

        $('#GridEnfermedades').each(function () {
            $(this).datagrid({
                dataSource: new EnfermedadesDataSource({
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
        error_catch(jqXHR, textStatus, errorThrown, false);
    });

}

function showEditDisease(id) {
    toggleLoading(true);
    $.getJSON("/api/diseases/" + id, function (data) {
        console.log(data);
        toggleLoading(false);
        $("#diseaseForm")[0].reset();
        $("#createButton").hide();
        $("#editButton").show();
        $("#modal-form").modal("show");
        $.each(data.disease, function (key, value) {
            if (key != "gender") {
                $("#diseaseForm").find("input[name='" + key + "']").val(value);
            }
        });
        switch(data.disease.gender){
            case 'M':
                $('input:radio[name=gender]')[0].checked = true;
                break;
            case 'F':
                $('input:radio[name=gender]')[1].checked = true;
                break;
            case 'B':
                $('input:radio[name=gender]')[2].checked = true;
                break;
        }
        $("#editButton").click(function(){
            editDisease(id);
        });
    });
}

function showDeleteDisease(id) {
    if (confirm('¿Estás seguro que quieres borrar esta enfermedad?')) {
        toggleLoading(true);
        $.delete("/api/diseases/" + id)
            .done(function (data) {
                toggleLoading(false);
                search();
                //$('#datagridEnfermedades').datagrid('reload');
                console.log(data);
            }).fail(function (jqXHR, textStatus, errorThrown) {
                error_catch(jqXHR, textStatus, errorThrown, false);
            });
    }
}

function showCreateDisease(id) {
    $("#createButton").show();
    $("#editButton").hide();
}

function createDisease(){
    console.log( $("#diseaseForm" ).serialize());
    $.post("/api/diseases", $( "#diseaseForm" ).serialize())
        .done(function(data){
            console.log(data);
            search();
            //$('#datagridEnfermedades').datagrid('reload');
            $("#modal-form").modal("hide");
        })
        .fail(function (jqXHR, textStatus, errorThrown) {
            error_catch(jqXHR, textStatus, errorThrown, false);
        });
}

function editDisease(id) {
    console.log($("#diseaseForm").serialize());
    $("#modal-form").modal("hide");
    toggleLoading(true);
    $.put("/api/diseases/"+id, $("#diseaseForm").serialize())
        .done(function (data) {
            toggleLoading(false);
            console.log(data);
            search();
            //$('#datagridEnfermedades').datagrid('reload');
            $("#modal-form").modal("hide");
        }).fail(function (jqXHR, textStatus, errorThrown) {
            error_catch(jqXHR, textStatus, errorThrown, false);
        });
}

var html_enfermedades;

$(document).ready(function(){
   html_enfermedades = $('#datagridEnfermedades').html(); 
});

search();