(function () {
  "use strict";
  angular
    .module("robotshop")
    .controller("collectionform", function ($scope, $http, $location) {
      $scope.products = [];
      $scope.categories = [];
      $scope.category = $location.search().category || "";
      $scope.sort = "name";
      $scope.matchesCategory = function (item) {
        return (
          !$scope.category || item.categories.indexOf($scope.category) !== -1
        );
      };
      $scope.selectCategory = function (cat) {
        $scope.category = cat;
      };
      $scope.load = function () {
        $scope.loading = true;
        $scope.error = "";
        $http
          .get("/api/catalogue/products")
          .then(function (res) {
            $scope.products = res.data;
            $scope.categories = Array.from(
              new Set(
                res.data.reduce(function (all, item) {
                  return all.concat(item.categories);
                }, []),
              ),
            );
          })
          .catch(function () {
            $scope.error =
              "The collection is temporarily unavailable. Please try again.";
          })
          .finally(function () {
            $scope.loading = false;
          });
      };
      $scope.load();
    });
})();
