# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $(".new_product .selectize, .edit_product .selectize").each ->
    optionUrl = $(this).data('add-option-url')
    $(this).selectize
      delimiter: ","
      render:
        option_create: (data, escape) ->
          "<div class='create'>Adicionar <strong>" + escape(data.input) + "</strong>&hellip;</div>"
      create: (input) ->
        { value: input, text: input }
      createOnBlur: true
      onOptionAdd: (value) ->
        $.post(optionUrl, {option: value})
    
