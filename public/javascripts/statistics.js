var app = angular.module('statistics', []);

app.controller('StatisticsController', ['$scope', '$http', function ($scope, $http) {

    $scope.type = 'count';
    $scope.disease = 'Cancer de Mama';
    $scope.results = {};

    function success_function(data) {
        $scope.results = data;
    }

    $scope.get_results = function () {
        var data = {};
        data.type = $scope.type;
        data.disease = $scope.disease;
        $http.post('api/statistics/query', data).success(success_function);
    };
}]);

