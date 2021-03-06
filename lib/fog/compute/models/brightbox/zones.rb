require 'fog/core/collection'
require 'fog/compute/models/brightbox/zone'

module Fog
  module Compute
    class Brightbox

      class Zones < Fog::Collection

        model Fog::Compute::Brightbox::Zone

        def all
          data = connection.list_zones
          load(data)
        end

        def get(identifier)
          return nil if identifier.nil? || identifier == ""
          data = connection.get_zone(identifier)
          new(data)
        rescue Excon::Errors::NotFound
          nil
        end

      end

    end
  end
end