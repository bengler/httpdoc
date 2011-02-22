## Calendar API that provides access to events.
#
# @title Events
# @url /api/v2/event
#
class Api::V2::EventController < Api::V2::AbstractAPIController

  ## Get a single event by its ID.
  #
  # @url get/:id
  # @short Get a single event
  # @param id The numeric ID of the event to get.
  # @param api_key API key.
  # @return The single event in Atom format.
  # @status 200
  # @example
  #   @request
  #   GET #{base_url}/get/123
  #   
  #   @response
  #   HTTP/1.1 200 OK
  #   Content-Type: application/xml; charset=utf-8
  #
  #   <feed xmlns:gd="http://schemas.google.com/g/2005" 
  #     xmlns:gcal="http://schemas.google.com/gCal/2005"
  #     xmlns:media="http://search.yahoo.com/mrss/"
  #     xmlns:georss="http://www.georss.org/georss" xmlns="http://www.w3.org/2005/Atom">
  #     ...
  #   </feed>
  # @end
  #
  def get
  end
  
  ## Find events matching a set of query criteria.
  #
  # @short Find events by query
  # @param q A text query. Specify this to filter results containing the specified
  #   full-text query. For example, @coldplay concert@ finds events containing the 
  #   words "coldplay" and "concert".
  # @param start_time If specified, only events where the start time is at the specified
  #   date and time or later will be returned. The date and time should be in 
  #   "RFC 3339":http://tools.ietf.org/html/rfc3339 format. If the time part is omitted,
  #   00:00 is assumed.
  # @param api_key API key.
  # @return Events in Atom format.
  # @status 200
  # @example
  #   @request
  #   GET #{base_url}/find?limit=10&start_time=2010-01-01
  #   
  #   @response
  #   HTTP/1.1 200 OK
  #   Content-Type: application/xml; charset=utf-8
  #
  #   <feed xmlns:gd="http://schemas.google.com/g/2005" 
  #     xmlns:gcal="http://schemas.google.com/gCal/2005"
  #     xmlns:media="http://search.yahoo.com/mrss/"
  #     xmlns:georss="http://www.georss.org/georss" xmlns="http://www.w3.org/2005/Atom">
  #     ...
  #   </feed>
  # @end
  #
  def find
  end

end
