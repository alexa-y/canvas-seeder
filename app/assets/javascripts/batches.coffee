# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$('.batches.new').ready ->
  $('#new_batch').formValidation(
    fields:
      'batch[params][number_of_courses_min]':
        validators:
          callback:
            message: 'Must be less than or equal to maximum courses'
            callback: rangeCallback.bind('number_of_courses')
      'batch[params][number_of_courses_max]':
        validators:
          callback:
            message: 'Must be greater than or equal to minimum courses'
            callback: rangeCallback.bind('number_of_courses')
      'batch[params][number_of_sections_min]':
        validators:
          callback:
            message: 'Must be less than or equal to maximum sections'
            callback: rangeCallback.bind('number_of_sections')
      'batch[params][number_of_sections_max]':
        validators:
          callback:
            message: 'Must be greater than or equal to minimum sections'
            callback: rangeCallback.bind('number_of_sections')
      'batch[params][number_of_teachers_min]':
        validators:
          callback:
            message: 'Must be less than or equal to maximum teachers'
            callback: rangeCallback.bind('number_of_teachers')
      'batch[params][number_of_teachers_max]':
        validators:
          callback:
            message: 'Must be greater than or equal to minimum teachers'
            callback: rangeCallback.bind('number_of_teachers')
      'batch[params][number_of_students_min]':
        validators:
          callback:
            message: 'Must be less than or equal to maximum students'
            callback: rangeCallback.bind('number_of_students')
      'batch[params][number_of_students_max]':
        validators:
          callback:
            message: 'Must be greater than or equal to minimum students'
            callback: rangeCallback.bind('number_of_students')
      'batch[params][number_of_assignments_min]':
        validators:
          callback:
            message: 'Must be less than or equal to maximum assignments'
            callback: rangeCallback.bind('number_of_assignments')
      'batch[params][number_of_assignments_max]':
        validators:
          callback:
            message: 'Must be greater than or equal to minimum assignments'
            callback: rangeCallback.bind('number_of_assignments')
      'batch[params][points_possible_min]':
        validators:
          callback:
            message: 'Must be less than or equal to maximum points possible'
            callback: rangeCallback.bind('points_possible')
      'batch[params][points_possible_max]':
        validators:
          callback:
            message: 'Must be greater than or equal to minimum points possible'
            callback: rangeCallback.bind('points_possible')
  ).on 'change', "[name$='min]'], [name$='max]']", (e) ->
    $.each $("[name$='min]'], [name$='max]']"), (index, field) ->
      $('#new_batch').formValidation 'revalidateField', field.name

rangeCallback = ->
  min = parseInt($("[name='batch[params][#{this.toString()}_min]']").val())
  max = parseInt($("[name='batch[params][#{this.toString()}_max]']").val())
  min <= max

$('.batches.show').ready ->
  if $('.progress-bar').length > 0
    window.progressInterval = setInterval(->
      batchId = window.location.pathname.match(/\/batches\/(\d+)/)
      unless batchId
        clearInterval(window.progressInterval)
        return
      $.ajax "/batches/#{batchId[1]}/progress",
        type: 'get'
        dataType: 'json'
        success: (data) ->
          if data.progress == 100
            clearInterval(window.progressInterval)
            window.location = window.location.pathname
          $('.progress-bar').css('width', "#{data.progress}%")
          $('.progress-bar').text("#{data.progress}%")
    , 5000);
