var RolesDataSource = function (options) {
    this._formatter = options.formatter;
    this._columns = options.columns;
    this._resultsId = options.resultsId
};

RolesDataSource.prototype = {

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

function reloadData(roles) {
    datasource._resultsId = roles;
    $('#GridRoles').datagrid('reload');
}


var datasource;
var roles;
var currentFuntions = [];

function loadRoles() {

    toggleLoading(true);

    $.getJSON('/api/roles', {}, function (data) {
        console.log(data);
        var ids = data.roles;
        roles = data.roles;
        datasource = new RolesDataSource({
            // Column definitions for Datagrid
            columns: [
                {
                    property: 'id',
                    label: 'Id',
                    sortable: true
                },
                {
                    property: 'name',
                    label: 'Nombre',
                    sortable: true
                },
                {
                    property: 'description',
                    label: 'Descripción',
                    sortable: true
                },
                {
                    property: 'funciones',
                    label: 'Funciones',
                    sortable: true
                },
                {
                    property: 'edit',
                    label: 'Editar',
                    sortable: true
                },
                {
                    property: 'delete',
                    label: 'Borrar',
                    sortable: true
                },
            ],

            // Create IMG tag for each returned image
            formatter: function (items) {
                $.each(items, function (index, item) {
                    item.edit = '<a target="_blank" onclick="showEditRol('+item.id+')"><center><i class="fa fa-user-md"></i></center></a>';
                    item.delete = '<a onclick="deleteRol('+item.id+')"><center><i class="fa fa-trash-o"></i></center></a>';
                    item.funciones = item.functions.map(function(val){return val.name}).join(", ")
                });
            },

            resultsId: ids
        });
        console.log(ids);
        $('#GridRoles').each(function () {
            $(this).datagrid({
                dataSource: datasource
            });
        });
        toggleLoading(false);
    }).fail(function (jqXHR, textStatus, errorThrown) {
        error_catch(jqXHR, textStatus, errorThrown, false);
    });
}

function appendFunctionTag(func) {
    currentFuntions.push(func);
    $("#currentFunctions").append('<div class="alert alert-info alert-block">' +
        '        <button type="button" class="close" onclick="deleteFuncion('+func.id+')"><i class="fa fa-times"></i></button>' +
        '    <h4><i class="fa fa-bell-alt"></i>' + func.name + '</h4>' +
        '        <p>' + func.description + '</p>' +
        '    </div>')
}

function deleteFuncion(id){
    currentFuntionsTemp=currentFuntions.filter(function(func){
        return func.id != id
    });
    currentFuntions=[];
    $("#currentFunctions").empty();
    $.each(currentFuntionsTemp,function(index,el){
        appendFunctionTag(el);
    });
    if(currentRole!=undefined){
        currentRole.functions= currentFuntions;
        reloadData(roles);
        $.delete("/api/roles/"+currentRole.id+"/functions/"+id)
            .done(function(data){
                console.log(data);
            })
    }
}

function agregarFuncion(){
    var func = functions.find(function (el) {
        return el.id == $("#functions").val()
    });
    var duplicated = currentFuntions.find(function (el) {
        return el.id == func.id
    });
    if(duplicated!=undefined){
        alert("Error: Función duplicada");
        return;
    }
    console.log(func.name);
    appendFunctionTag(func);
    if(currentRole!=undefined){
        currentRole.functions= currentFuntions;
        reloadData(roles);
        $.put("/api/roles/"+currentRole.id+"/functions/"+func.id)
            .done(function(data){
                console.log(data);
            })
    }
}

function deleteRol(id){
    var rol = roles.find(function (rol) {
        return rol.id == id
    });
    roles=roles.filter(function(rol){
        return rol.id != id
    });
    reloadData(roles);
    console.log(rol.name);
    $.delete("/api/roles/"+id)
        .done(function(data){
            console.log(data);
        })
        .fail(function (jqXHR, textStatus, errorThrown) {
            error_catch(jqXHR, textStatus, errorThrown, false);
        });
}

var currentRole;
function showEditRol(id){
    var rol = roles.find(function (rol) {
        return rol.id == id
    });
    currentRole = rol;

    currentFuntions=[];
    $("#currentFunctions").empty();
    $.each(rol.functions,function(index,el){
        appendFunctionTag(el);
    });
    $("#createButton").hide();
    $("#editButton").show();
    $.each(rol, function (key, value) {
        if (key != "gender") {
            $("#roleForm").find("input[name='" + key + "']").val(value);
        }
    });
    $("#modal-form").modal("show");
}
function showCreateRol(){
    $("#modal-form").modal("show");
    $("#rolesDiv").show();
    $("#createButton").show();
    $("#editButton").hide();
    $("#roleForm")[0].reset();
    $("#currentFunctions").empty();
    currentFuntions=[];
    currentRole=undefined;
}

function createRol() {
    $("#modal-form").modal("hide");
    toggleLoading(true);
    $.post("/api/roles",{name:$("#name").val(),description:$("#description").val()})
        .done(function(data){
            $.each(currentFuntions,function(index,func){
                $.put("/api/roles/"+data.role.id+"/functions/"+func.id)
                    .done(function(data){
                        console.log(data);
                    })
            });
            console.log(data);
            toggleLoading(false);
            data.role.functions= currentFuntions;
            roles.push(data.role);
            reloadData(roles);

        })
        .fail(function (jqXHR, textStatus, errorThrown) {
            error_catch(jqXHR, textStatus, errorThrown, false);
        });
}

function editRol(){
    $("#modal-form").modal("hide");
    toggleLoading(true);
    $.put("/api/roles/"+currentRole.id,{name:$("#name").val(),description:$("#description").val()})
        .done(function(data){
            console.log(data);
            toggleLoading(false);
            currentRole.name=data.role.name;
            currentRole.description=data.role.description;
//            roles.push(data.role);
            reloadData(roles);
        })
        .fail(function (jqXHR, textStatus, errorThrown) {
            error_catch(jqXHR, textStatus, errorThrown, false);
        });
}

var functions;
function loadFunctions(){
    $.getJSON('/api/functions')
        .done(function(data){
            functions = data.functions;
            $.each(data.functions, function (key, val) {
                $("#functions").append('<option value="'+val.id+'">'+val.name+'</option>');
            });
        })
        .fail(function (jqXHR, textStatus, errorThrown) {
            error_catch(jqXHR, textStatus, errorThrown, false);
        });
}


loadRoles();
loadFunctions();
