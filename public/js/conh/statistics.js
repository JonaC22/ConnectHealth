var app = angular.module('statistics', []);

app.controller('StatisticsController', ['$scope', '$http', function ($scope, $http) {

    $scope.type = 'count';
    $scope.degree = 'fdr';
    $scope.options = 'both';
    $scope.results = {};

    function success_function(data) {
        $scope.results = data;
        toggleLoading(false);
    }

    $scope.get_results = function () {
        toggleLoading(true);
        var data = {};
        data.type = $scope.type;
        data.disease = $scope.disease.value;
        data.degree = $scope.degree;
        data.options = $scope.options;
        $http.post('api/statistics/query', data).success(success_function);
    };

    toggleLoading(true);
    $http.get('/api/diseases').success(success_get_diseases);

    function success_get_diseases(data) {
        var diseases = [];

        data.diseases.forEach(function(d){
            delete d.id;
            d.value = d.name;
            diseases.push(d);
        });

        $scope.diseases = diseases;
        $scope.disease = diseases[0];

        toggleLoading(false);
    }
}]);

