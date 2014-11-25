  class SimulatorView extends Backbone.View
    template: JST['simulator/templates/simulator']

    constructor: (opts)->
      super(opts)
      console.debug 'Constructing Simulator'

      Twilio.Device.setup opts.twilio_token
      Twilio.Device.ready (device) ->
        $("#log").text "Ready"
        return

      Twilio.Device.error (error) ->
        $("#log").text "Error: " + error.message
        return

      Twilio.Device.connect (conn) ->
        $("#log").text "Successfully established call"
        return

      Twilio.Device.disconnect (conn) ->
        $("#log").text "Call ended"
        return

      Twilio.Device.incoming (conn) ->
        $("#log").text "Incoming connection from " + conn.parameters.From
        conn.accept()
        return



    # accept the incoming connection and start two-way audio
    call = ->
      Twilio.Device.connect()

    hangup = ->
      Twilio.Device.disconnectAll()

    render: ->
      @$el.html(@template(@data))
      this


  window.SimulatorView = SimulatorView

