benv = require 'benv'
_ = require 'underscore'
Backbone = require 'backbone'
sinon = require 'sinon'
Sale = require '../../../models/sale.coffee'
Artwork = require '../../../models/artwork.coffee'
SaleArtworks = require '../../../collections/sale_artworks.coffee'
{ resolve } = require 'path'
AuctionReminder = benv.requireWithJadeify resolve(__dirname, '../index'), ['auctionTemplate']
{ fabricate } = require 'antigravity'
moment = require 'moment'

describe 'AuctionReminder', ->
  beforeEach (done) ->
    benv.setup =>
      benv.expose { $: benv.require 'jquery' }
      Backbone.$ = $
      sinon.stub Backbone, 'sync'
      @reminder = new AuctionReminder
      AuctionReminder.__set__ 'Cookies', sinon.stub()
      done()

  afterEach ->
    benv.teardown()
    Backbone.sync.restore()
    AuctionReminder.__set__ 'Cookies', sinon.restore()

  describe '#module.exports', ->
    it 'fetches auction and auction image if there is one', ->
      Backbone.sync.args[0][2].success [fabricate('sale', { id: "fake-sale" }), fabricate('sale')]
      Backbone.sync.args[1][2].success [fabricate('artwork', { id: "fake-artwork" }), fabricate('artwork')]
      Backbone.sync.args[2][1].get('id').should.equal "fake-artwork"

    it 'returns an error if there are no auctions', ->
      Backbone.sync.args[0][2].error()

describe 'AuctionReminderModal', ->
  beforeEach (done) ->
    benv.setup =>
      benv.expose { $: benv.require 'jquery' }
      Backbone.$ = $
      sinon.stub Backbone, 'sync'
      @AuctionReminderModal = AuctionReminder.__get__ 'AuctionReminderModal'
      @AuctionReminderModal::open = sinon.stub()
      @cookies = sinon.stub(AuctionReminder.__get__ 'Cookies', 'initialize')
      # console.log @cookies
      # sinon.stub(@cookies)
      @auctionImage = "foo.jpg"
      done()

  afterEach ->
    benv.teardown()
    Backbone.sync.restore()
    @cookies.restore()


  describe '#initialize', ->

    it 'displays if there are less than 24 hours until the end of the auction', ->
      auction = new Sale fabricate 'sale', { end_at: moment().add(5,'hours') }
      view = new @AuctionReminderModal(
        auction: auction
        auctionImage: @auctionImage
      )
      _.isUndefined(view.$container).should.equal false
    
    it 'displays if there are less than 24 hours until the end, part two', ->
      auction = new Sale fabricate 'sale', { end_at: moment().add(23,'hours').add(59,'minutes') }
      view = new @AuctionReminderModal(
        auction: auction
        auctionImage: @auctionImage
      )
      _.isUndefined(view.$container).should.equal false

    it 'does not display if there are more than 24 hours until the end', ->
      auction = new Sale fabricate 'sale', { end_at: moment().add(25,'hours') }
      view = new @AuctionReminderModal(
        auction: auction
        auctionImage: @auctionImage
      )
      _.isUndefined(view.$container).should.equal true

