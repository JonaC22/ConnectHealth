var EstadisticasDataSource = function (options) {
    this._formatter = options.formatter;
    this._columns = options.columns;
    this._resultsId = options.resultsId
};

EstadisticasDataSource.prototype = {

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

        // SORTING
        if (options.sortProperty) {
            self._resultsId = _.sortBy(self._resultsId, options.sortProperty);
            if (options.sortDirection === 'desc') self._resultsId.reverse();
        }
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

var app = angular.module('statistics', []);

app.controller('StatisticsController', ['$scope', '$http', function ($scope, $http) {

    $scope.type = 'count';
    $scope.degree = 'fdr';
    $scope.options = 'both';
    $scope.results = {};

    function success_function(data) {
        //$scope.results = data;
        fill_grid(data.data);
        toggleLoading(false);
    }

    $scope.get_results = function () {
        toggleLoading(true);
        var data = {};
        data.type = $scope.type;
        data.disease = $scope.disease.value;
        data.degree = $scope.degree;
        data.options = $scope.options;
        $http.post('api/statistics/query', data).then(success_function, fail_function);
    };

    toggleLoading(true);
    $http.get('/api/diseases').then(success_get_diseases, fail_function);

    function success_get_diseases(data) {
        var diseases = [];

        data.data.diseases.forEach(function(d){
            delete d.id;
            d.value = d.name;
            diseases.push(d);
        });

        $scope.diseases = diseases;
        $scope.disease = diseases[0];

        toggleLoading(false);
    }

    function fail_function(response){
        alert(response);
        console.log(response);
    }
}]);

function transform_for_grid(data){
    var results = [];
    console.log(data);
    for(var i = 0; i < data.data.length; i++){
        console.log(data.data[i]);
        var obj = {};
        obj.Cantidad = data.data[i][0];
        obj.Edad = data.data[i][1];
        results.push(obj);
    }
    return results;
}

function fill_grid(data) {
    data = transform_for_grid(data);
    console.log(data);
    $('#GridEstadisticas').each(function () {
            $(this).datagrid({
                dataSource: new EstadisticasDataSource({
                    // Column definitions for Datagrid
                    columns: [
                        {
                            property: 'Cantidad',
                            label: 'Cantidad',
                            sortable: true
                        },
                        {
                            property: 'Edad',
                            label: 'Edad',
                            sortable: true
                        }
                    ],

                    resultsId: data
                })
            });
    });
}