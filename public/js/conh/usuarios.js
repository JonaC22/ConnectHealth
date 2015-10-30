var UsuariosDataSource = function (options) {
    this._formatter = options.formatter;
    this._columns = options.columns;
    this._resultsId = options.resultsId
};

UsuariosDataSource.prototype = {

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

function createUser(){
    console.log( $("#userForm" ).serialize());
    var email = $("#email").val();
    var displayName = $("#display_name").val();
    var password = $("#password").val();
    $("#modal-form").modal("hide");
    $("#userForm")[0].reset();
    toggleLoading(true);
    $.post("/api/users",  {"user": { "email": email, "password":password, "password_confirmation":password, "display_name" : displayName} })
        .done(function(data){
            console.log(data);
            $('#GridUsuarios').datagrid('reload');
            $.getJSON('/api/users', {}, function (data) {
                toggleLoading(false);
                console.log(data);
                var ids = data.users;
                datasource._resultsId = ids;
                $('#GridUsuarios').datagrid('reload');
            });
        })
        .fail(function (jqXHR, textStatus, errorThrown) {
            error_catch(jqXHR, textStatus, errorThrown, false);
        });
}

var datasource;
function loadUsers() {

    toggleLoading(true);
    $.getJSON('/api/users', {}, function (data) {
        console.log(data);
        var ids = data.users;
        datasource = new UsuariosDataSource({
            // Column definitions for Datagrid
            columns: [
                {
                    property: 'id',
                    label: 'Id',
                    sortable: true
                },
                {
                    property: 'display_name',
                    label: 'Usuario',
                    sortable: true
                },
                {
                    property: 'email',
                    label: 'Email',
                    sortable: true
                },
                {
                    property: 'role',
                    label: 'Rol',
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
                    item.edit = '<a target="_blank" href=""><center><i class="fa fa-user-md"></i></center></a>';
                    item.delete = '<a href="" onclick=""><center><i class="fa fa-trash-o"></i></center></a>';
                });
            },

            resultsId: ids
        });
        console.log(ids);
        $('#GridUsuarios').each(function () {
            $(this).datagrid({
                dataSource: datasource
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

loadUsers();