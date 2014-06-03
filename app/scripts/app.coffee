'use strict'

app = angular.module('holmesApp', [
  'ngCookies',
  'ngSanitize',
  'ngRoute',
  'angularMoment',
  'restangular',
  'reconnectingWebSocket',
  'ngCookies',
  'googleplus',
  'HolmesWebPackageJson',
  'ngAnimate',
  'ngDropdowns',
  'ng-breadcrumbs',
  'gettext',
  'ngTagsInput',
  'growlNotifications',
  'qtip2'
])
  .config ($routeProvider, RestangularProvider, ConfigConst, GooglePlusProvider) ->
    gettextCatalog =
      getString: (message) -> message

    $routeProvider
      .when '/',
        redirectTo: '/domains'
      .when '/domains',
        templateUrl: 'views/domains.html'
        controller: 'DomainsCtrl'
        label: gettextCatalog.getString("Domains")
      .when '/domains/:domainName',
        templateUrl: 'views/domain.html'
        controller: 'DomainCtrl'
        label: 'Domain'
      .when '/domains/:domainName/violations/prefs',
        templateUrl: 'views/domain-violations-prefs.html'
        controller: 'DomainsViolationsPrefsCtrl'
        label: 'Violations preferences'
      .when '/domains/:domainName/page/:pageId/review/:reviewId',
        templateUrl: 'views/reviews.html'
        controller: 'ReviewsCtrl'
        reloadOnSearch: false
        label: 'Review'
      .when '/violations',
        redirectTo: -> '/'
        label: gettextCatalog.getString("Violations")
      .when '/violations/:violationKey',
        templateUrl: 'views/violation.html'
        controller: 'ViolationCtrl'
        label: 'Violation'
      .when '/status',
        redirectTo: '/status/workers'
        label: gettextCatalog.getString("Status")
      .when '/status/workers',
        templateUrl: 'views/workers.html'
        controller: 'WorkersCtrl'
        label: gettextCatalog.getString("Workers")
      .when '/status/last-reviews',
        templateUrl: 'views/last-reviews.html'
        controller: 'LastReviewsCtrl'
        label: gettextCatalog.getString("Last Reviews")
      .when '/status/pipeline',
        templateUrl: 'views/review-pipeline.html'
        controller: 'ReviewPipelineCtrl'
        label: gettextCatalog.getString("Review Pipeline")
      .when '/status/requests',
        templateUrl: 'views/last-requests.html'
        controller: 'LastRequestsCtrl'
        label: gettextCatalog.getString("Last Requests")
      .when '/status/concurrent',
        templateUrl: 'views/concurrent.html'
        controller: 'ConcurrentCtrl'
        label: gettextCatalog.getString("Concurrent Requests")
      .otherwise
        redirectTo: '/'
    RestangularProvider.setBaseUrl(ConfigConst.baseUrl)
    RestangularProvider.addFullRequestInterceptor(
      (element, operation, what, url, headers, query) ->
        storage = window.sessionStorage

        selectedLanguage = storage.getItem('selectedLanguage')
        if not selectedLanguage?
          selectedLanguage = "en_US"

        headers['Accept-Language'] = selectedLanguage
    )
    GooglePlusProvider.init({
      clientId: '968129569472-1smbhidqeo3kpdj029cehmnp8qh808kv',
      apiKey: '68129569472-1smbhidqeo3kpdj029cehmnp8qh808kv.apps.googleusercontent.com',
      scopes: 'https://www.googleapis.com/auth/plus.login https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile'
    })
  .run(($rootScope, $window, ConfigConst, gettextCatalog) ->
    gettextCatalog.currentLanguage = ConfigConst.currentLanguage
    gettextCatalog.debug = ConfigConst.gettextDebug

    $rootScope.$on('$viewContentLoaded', ->
      $window.scrollTo(0, 0)
    )
  )
