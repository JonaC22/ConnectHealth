function createDisease(){
    console.log( $("#diseaseForm" ).serialize());
    $.post("/api/diseases", $( "#diseaseForm" ).serialize())
        .done(function(data){
            console.log(data);
            $("#modal-form").modal("hide")
            search();
        })
        .fail(function (jqXHR, textStatus, errorThrown) {
            console.log(textStatus);
            console.log(errorThrown);
            toggleLoading(false);
            alert("Error: " + jqXHR.status + " " + errorThrown);
        });
}

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

//TODO limpiar tabla antes de volver a repopular
function search() {
    toggleLoading(true);

    $.getJSON('/api/diseases', {}, function (data) {
        console.log(data);
        var ids = data.diseases;
        console.log(ids);

        $('#GridEnfermedades').each(function () {
            $(this).datagrid({
                dataSource: new PubMedDataSource({
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
                    ],

                    // Create IMG tag for each returned image
                    formatter: function (items) {
                        $.each(items, function (index, item) {
                            item.ext_link = '<a target="_blank" href="http://www.ncbi.nlm.nih.gov/pubmed/' + item.uid + '"><center><i class="fa fa-user-md"></i></center></a>';
                            item.extract = '<a href="#verExtracto" onclick="verExtracto(\'' + item.uid + '\',\'' + item.title + '\')"><center><i class="fa fa-eye"></i></center></a>';
                            item.fullTextArticleLink = '';
                        });
                    },
                    resultsId: ids
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

search();