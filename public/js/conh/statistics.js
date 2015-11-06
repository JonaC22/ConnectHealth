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
        callback({data: self._resultsId, start: startIndex, end: end, count: count, pages: pages, page: page});
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
        console.log(data.data);
        fill_grid(data.data.statistical_report.result);
        toggleLoading(false);
    }

    $scope.get_results = function () {
        toggleLoading(true);
        var data = {};
        data.type = $scope.type;
        data.disease = $scope.disease.value;
        data.degree = $scope.degree;
        data.options = $scope.options;
        $http.post('api/statistical_reports', data).then(success_function, fail_function);
    };

    toggleLoading(true);
    $http.get('/api/diseases').then(success_get_diseases, fail_function);

    function success_get_diseases(data) {
        var diseases = [];

        data.data.diseases.forEach(function (d) {
            delete d.id;
            d.value = d.name;
            diseases.push(d);
        });

        $scope.diseases = diseases;
        $scope.disease = diseases[0];

        toggleLoading(false);
    }

    function fail_function(response) {
        alert(response);
        console.log(response);
    }
}]);

function transform_for_grid(data) {
    var results = [];
    console.log(data);
    $.each(data.data, function (i) {
        console.log(data.data[i]);
        var obj = {};
        $.each(data.columns, function (k) {
            obj[data.columns[k]] = data.data[i][k];
        });
        results.push(obj);
    });
    return results;
}

function fill_grid(data) {
    $('#datagridEstadisticas').show();
    var data_columns = [];
    console.log(data.columns);
    $.each(data.columns, function (d) {
        var column = {};
        column.property = data.columns[d];
        column.label = data.columns[d];
        column.sortable = true;
        data_columns.push(column);
    });
    console.log(data_columns);
    var res = data;
    data = transform_for_grid(data);
    console.log(data);

    $('#datagridEstadisticas').html(html_grid_estadisticas);
    $('#GridEstadisticas').datagrid({
        dataSource: new EstadisticasDataSource({
            // Column definitions for Datagrid
            columns: data_columns,
            resultsId: data
        })
    });

    $('#charts').hide();
    if(res.columns.length > 1 && res.data.length > 1){

        var buildMorris = function($re){
            if($re){
                $('.graph').html('');
            }
            var data_donut = transform_data_donut(res);
            data_donut.sort(function (a,b) {
                if (a.value < b.value)
                    return -1;
                if (a.value > b.value)
                    return 1;
                return 0;
            });
            console.log(data_donut);
            Morris.Donut({
                element: 'hero-donut',
                data: data_donut,
                colors:['#afcf6f'],
                formatter: function (y) { return y + "%" }
            });
        };

        var data_chart = transform_data_chart(res);
        var ykeys = [];
        ykeys.push(res.columns[0]);

        data_chart.sort(function (a,b) {
            if (a[res.columns[1]] < b[res.columns[1]])
                return -1;
            if (a[res.columns[1]] > b[res.columns[1]])
                return 1;
            return 0;
        });

        var buildArea = function(){
            Morris.Area({
                element: 'hero-area',
                data: data_chart,
                xkey: res.columns[1],
                ykeys: ykeys,
                labels: ykeys,
                hideHover: 'auto',
                lineWidth: 2,
                pointSize: 4,
                lineColors: ['#59dbbf'],
                fillOpacity: 0.5,
                smooth: true,
                hoverCallback: function(index, options, content) {
                    var data = options.data[index];
                    $(".morris-hover").html('<div>'+ykeys[0]+': '+ data[ykeys[0]]+'<br>'+res.columns[1]+': '+ data[res.columns[1]] + '</div>');
                }
            });
        };

        $('#charts').show();

        buildMorris(false);
        var morrisResize;
        $(window).resize(function(e) {
            clearTimeout(morrisResize);
            morrisResize = setTimeout(function(){buildMorris(true)}, 500);
        });

        $('#charts #hero-area').each(function(){
            buildArea();
            var morrisResizes;
            $(window).resize(function(e) {
                clearTimeout(morrisResizes);
                morrisResizes = setTimeout(function(){
                    $('.graph').html('');
                    buildArea();
                }, 500);
            });
        });
    }
}

function transform_data_chart(data){
    var array = [];
    for(var i=0; i < data.data.length; i++) {
        var json = {};
        for (var k = 0; k < data.columns.length; k++) {
            json[data.columns[k]] = data.data[i][k];
        }
        array.push(json);
    }
    return array;
}

function transform_data_donut(data){
    var array = [];
    res = transform_data_chart(data);
    var total = 0;
    for(var i = 0; i < res.length; i++){
        total += res[i][data.columns[0]];
    }
    for(var i = 0; i < res.length; i++){
        var json = {};
        json.label = res[i][data.columns[1]];
        json.value = res[i][data.columns[0]] * 100 / total;
        json.value = json.value.toFixed(2);
        array.push(json);
    }
    return array;
}

var html_grid_estadisticas;

$(document).ready(function(){
    html_grid_estadisticas = $('#datagridEstadisticas').html();
    $('#charts').hide();
});


