module Shippinglogic
  class USPS
    class Track < Service
      def self.api
        "TrackV2"
      end

      class Details
        # Each tracking result is an object of this class
        class Event; attr_accessor :name, :status, :event_time, :event_date, :city, :state, :postal_code, :country, :authorized_agent, :firm_name; end

        attr_accessor :authorized_agent, :status, :delivery_at, :events

        def initialize(response)
          response = response[:track_response][:track_info]
          self.events = [response[:track_summary], response[:track_detail]].flatten.compact.collect do |details|
            event = Event.new
            event.authorized_agent = details[:authorized_agent]
            event.name = details[:name]
            event.status = details[:event]
            event.event_date = details[:event_date]
            event.event_time = details[:event_time]
            event.city = details[:event_city]
            event.state = details[:event_state]
            event.postal_code = details[:event_zipcode]
            event.country = details[:event_country]
            event
          end
        end

      end

      attribute :tracking_number, :string

      private
      # The parent class Service requires that we define this method. This is our kicker. This method is only
      # called when we need to deal with information from USPS. Notice the caching into the @target variable.
      def target
        @target ||= Details.new(request(build_request))
      end

      # Just building some XML to send off to USPS.
      def build_request
        b = builder
        xml = b.TrackFieldRequest("USERID" => base.username) do
          b.TrackID("ID"=> tracking_number)
        end
        xml
      end
    end
  end
end