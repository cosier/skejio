class Scplanner.Models.User extends Backbone.Model
  paramRoot: 'user'

  defaults:
    sort_order: 0

  url: ->
    "/businesses/#{Scp.business_id}/users"

class Scplanner.Collections.UsersCollection extends Backbone.Collection
  model: Scplanner.Models.User
  url: ->
    "/businesses/#{Scp.business_id}/users"
