_ = require 'underscore'
Backbone = require 'backbone'
imagesLoaded = require 'imagesloaded'
Flickity = require 'flickity'
Artwork = require '../../../../models/artwork.coffee'
ShareView = require '../../../../components/share/view.coffee'
DeepZoomView = require '../../../../components/deep_zoom/view.coffee'
analyticsHooks = require '../../../../lib/analytics_hooks.coffee'

module.exports = class ArtworkImageView extends Backbone.View
  events:
    'click .artwork-header-module__favorite-button': 'savedArtwork'
    'click .artwork-header-module__watch-button': 'watchArtwork'
    'click .artwork-image': 'initZoom'
    'pinchOut .artwork-image': 'initZoom'

  initialize: ({ @artwork, @user }) ->
    @renderSave()
    artistsNames = _.pluck(@artwork.artists, 'name').join(', ') if @artwork.artists.length
    new ShareView
      el: @$('.artwork-header-module__share-button'),
      imageUrl: @artwork.image.url,
      description: if artistsNames then "#{artistsNames}, #{@artwork.title} @artsy" else "#{@artwork.title} @artsy"

    if @artwork.images.length > 1
      @slideshow = new Flickity '#artwork-carousel__track',
        prevNextButtons: false
        imagesLoaded: true
        draggable: true

  renderSave: ->
    if @user
      @user.savedArtwork @artwork.id,
        success: (saved) =>
          if saved
            @$('.artwork-header-module__favorite-button, .artwork-header-module__watch-button').attr
              'data-state': 'saved'
              'data-action': 'remove'
    else
      @$('.artwork-header-module__favorites-container a').attr("href", "/sign_up?action=save&objectId=#{@artwork.id}&kind=artwork&redirect-to=#{window.location}&signupIntent=save+artwork&intent=save+artwork&trigger=click&contextModule=Artwork+Page")
      @$('.artwork-header-module__favorites-container').click( (e) ->
        analyticsHooks.trigger 'save:sign-up'
      )

  savedArtwork: (e) ->
    if @user
      e.preventDefault()
      $saveButton = @$('.artwork-header-module__favorite-button')
      action = $saveButton.attr('data-action')
      @user["#{action}Artwork"](@artwork.id)

      analyticsHooks.trigger "save:#{action}-artwork", {
        entity_id: @artwork._id
        entity_slug: @artwork.id
        context_module: 'Artwork page'
      }

      $saveButton.attr
        'data-state': (if action is 'save' then 'saved' else 'unsaved')
        'data-action': (if action is 'save' then 'remove' else 'save')

  watchArtwork: (e) ->
    if @user
      e.preventDefault()
      $watchButton = @$('.artwork-header-module__watch-button')
      action = $watchButton.attr('data-action')
      @user["#{action}Artwork"](@artwork.id)

      analyticsHooks.trigger "save:#{action}-artwork", {
        entity_id: @artwork._id
        entity_slug: @artwork.id
        context_module: 'Artwork page'
      }

      $watchButton.attr
        'data-state': (if action is 'save' then 'saved' else 'unsaved')
        'data-action': (if action is 'save' then 'remove' else 'save')

  initZoom: (e) ->
    $('html, body').scrollTop 0
    artwork = new Artwork @artwork
    artwork.fetch()

    @zoom = new DeepZoomView model: artwork
    @$el.append @zoom.render().$el
