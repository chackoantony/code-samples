(function(){

  app = angular.module('credit_card_filter', []);
   
  app.controller('CreditCardController', ["$scope", "$http", "$filter", "$sce", "$location", function ($scope, $http, $filter, $sce, $location) { 
    
    $scope.sortKey = 'interest';
    $scope.reverse = true;
    $scope.packages = [];
    $scope.total_packages = [];
    $scope.filtered_packages = [];
    $scope.current_page = 1;
    $scope.per_page = 10;
    $scope.filter_key = 'cash_back'
    $scope.bank = $location.search()['bank']
    $scope.card_type = $location.search()['card-type']
  

    $scope.open_modal = function(package){
      url = package.bank_page_url
      if(url == null || url.trim() == ''){
        $('#selected_card').val(package.id)
        $('#policy_url').attr('href', package.policy_url)
        $('#apply_credit_card_form').modal('show')
      }else{
        location.href = url
      }
    }
    $scope.update_list = function(bank){
      $scope.bank = bank
      url = '/credit-card?bank=' + bank
      if($scope.card_type){
        url += '&card-type=' + $scope.card_type   
      }
      $location.url(url)
      $scope.filtered_packages = $filter('filter')($scope.total_packages, { bank_name:$scope.bank});
      $scope.packages =  $scope.filtered_packages.slice(0, $scope.per_page)
      _gaq.push(['_trackEvent', 'creditCard', 'bank_filter'])  
    }

    $scope.load_more = function(){
      $scope.current_page += 1;
      $scope.packages = $scope.filtered_packages.slice(0, $scope.per_page * $scope.current_page)
      _gaq.push(['_trackPageview'])
    }

       
    $scope.filter_loans = function(){
      params = {'card-type': $scope.card_type, bank: $scope.bank}
      $scope.get_cards(params)
    }

    $scope.get_cards = function(params){
      $http({url: '/credit-card/find_cards.json', params: params}).success(function(data){
        $scope.total_packages =  $filter('orderObjectBy')(data.credit_cards, $scope.sortKey, $scope.reverse)
        $scope.filtered_packages = $filter('filter')($scope.total_packages, { bank_name:$scope.bank});
        $scope.packages =  $scope.filtered_packages.slice(0, $scope.per_page)
      });
      _gaq.push(['_trackPageview'])  
    }

  
    $scope.change_type = function(type){
      $scope.card_type = type
      $scope.bank = ''
      $scope.filter_loans()
    }

    $(window).on("popstate", function(e) {
      params = $location.search()
      $scope.card_type = params['card-type']
      $scope.bank =  params['bank']
      $scope.filter_loans()
    });


    $scope.sort = function(keyname){
      $scope.sortKey = keyname;   
      $scope.reverse = !$scope.reverse;
      $scope.filtered_packages =  $filter('orderObjectBy')($scope.filtered_packages, $scope.sortKey, $scope.reverse)
      $scope.packages =  $scope.filtered_packages.slice(0, $scope.per_page)
      _gaq.push(['_trackEvent', 'creditCard', 'sort'])
    }

    $scope.filter_loans()


  }]);

  //custom filter
  app.filter('orderObjectBy', function() {
    return function(items, field, reverse) {
      texts = []
      numbers = []
      angular.forEach(items, function(item) {
        if(isNaN(item[field])){
          texts.push(item)
        }else{
          numbers.push(item)
        }
      });

      texts.sort(function(a, b) {
        if(a[field] == b[field]){
          return 0
        }else{
          return (a[field] > b[field] ? 1 : -1);
        }
      });
    
      numbers.sort(function(a, b) {
        if(a[field] == b[field]){
          return 0
        }else{
          return (a[field] > b[field] ? 1 : -1);
        }
      });

      filtered = texts.concat(numbers)
      if(reverse) filtered.reverse();
      return filtered;
    };
  });


  app.filter('percentage', ['$filter', function($filter) {
    return function(input, decimals, none_value) {
      if(input < 1){
        return none_value 
      }else{
        return input.toFixed(decimals).replace(/\.?0+$/, '') + '%'
      }
    };
  }]);

  app.filter('cut', ['$filter', function($filter) {
    return function (value, wordwise, max, tail) {
      if (!value) return '';

      max = parseInt(max, 10);
      if (!max) return value;
      if (value.length <= max) return value;

      value = value.substr(0, max);
      if (wordwise) {
        var lastspace = value.lastIndexOf(' ');
        if (lastspace != -1) {
          if (value.charAt(lastspace-1) == '.' || value.charAt(lastspace-1) == ',') {
            lastspace = lastspace - 1;
          }
          value = value.substr(0, lastspace);
        }
      }
      return value + (tail || ' …');
    };
  }]);

  
  app.config([ '$locationProvider', function($locationProvider) {
    $locationProvider.html5Mode(true);
  }]);


})();