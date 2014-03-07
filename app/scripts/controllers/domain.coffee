'use strict'

class DomainCtrl
  constructor: (@scope, @DomainsFcty, @domainName, @WebSocketFcty) ->
    @selectedCategory = null
    @numberOfPages = 0
    @reviewCount = 0
    @domain_url = ''
    @reviewFilter = ''
    @reviews = {}

    @getDomainViolations()
    @getReviewsData()
    @getDomainDetails()
    @watchScope()

    @WebSocketFcty.on((message) =>
      if message.type == 'new-page' or message.type == 'new-review'
        @getDomainDetails()
        @getReviewsData()
    )

    @violationData = {}

  _fillViolationData: (data) =>
    @violationData[data.categoryId] = data.violations

  _fillDomainGroupedViolations: (data) =>
    for violation in data.violations
      @DomainsFcty.getDomainMostCommonViolations(data.domainName, violation.categoryId).then(@_fillViolationData)

    @domainGroupedViolations = _.map(
      data.violations,
      (violation, i) ->
        id: violation.categoryId
        label: violation.categoryName + ' Violations'
        value: 100 * violation.count / this.total
        pageCount: violation.count
        color: 'color' + (i + 1)
      data)

    @selectedCategory =
      title: @domainGroupedViolations[0].label
      percentage: @domainGroupedViolations[0].value
      pageCount: @domainGroupedViolations[0].pageCount
      color: @domainGroupedViolations[0].color
      violations: @violationData[@domainGroupedViolations[0].id]

  _fillReviews: (data) =>
    @reviews = data
    @reviewCount = @reviews.reviewCount
    @numberOfPages = @reviewCount

  _fillDomainDetails: (data) =>
    @domain_details = data
    @domain_url = if data.url.slice(-1) == '/' then data.url else "#{ data.url }/"

  getDomainViolations: ->
    @DomainsFcty.getDomainGroupedViolations(@domainName).then(@_fillDomainGroupedViolations)

  getReviewsData: (currentPage, pageSize) ->
    filter = @domain_url + @reviewFilter
    params =
      current_page: currentPage
      page_size: pageSize
      term: filter
    @DomainsFcty.getDomainReviews(@domainName, params).then(@_fillReviews)

  getDomainDetails: ->
    @DomainsFcty.getDomainData(@domainName).then(@_fillDomainDetails)

  onSelect: (value, data) =>
    if data?
      @selectedCategory =
        title: data.label
        percentage: data.value
        pageCount: data.pageCount
        color: data.color
        violations: @violationData[data.id]
    else
      @selectedCategory = null

  updateReviews: (currentPage, pageSize) =>
    @getReviewsData(currentPage, pageSize)

  watchScope: ->
    updateReviewData = $.debounce(500, =>
      @getReviewsData()
    )

    @scope.$watch('model.reviewFilter', updateReviewData)

angular.module('holmesApp')
  .controller 'DomainCtrl', ($scope, DomainsFcty, $routeParams, WebSocketFcty) ->
    $scope.model = new DomainCtrl($scope, DomainsFcty, $routeParams.domainName, WebSocketFcty)
