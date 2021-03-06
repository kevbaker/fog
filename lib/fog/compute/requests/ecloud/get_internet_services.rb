module Fog
  module Compute
    class Ecloud

      class Real
        basic_request :get_internet_services
      end

      class Mock
        #
        #Based off of:
        #http://support.theenterprisecloud.com/kb/default.asp?id=580&Lang=1&SID=
        #http://support.theenterprisecloud.com/kb/default.asp?id=560&Lang=1&SID=
        #
        #

        def get_internet_services(internet_services_uri)
          internet_services_uri = ensure_unparsed(internet_services_uri)
          xml = nil

          if vdc_internet_service_collection = mock_data.vdc_internet_service_collection_from_href(internet_services_uri)
            xml = generate_internet_services(vdc_internet_service_collection.items)
          elsif public_ip_internet_service_collection = mock_data.public_ip_internet_service_collection_from_href(internet_services_uri)
            xml = generate_internet_services(public_ip_internet_service_collection.items)
          end

          if xml
            mock_it 200,
              xml, { 'Content-Type' => 'application/vnd.tmrk.ecloud.internetServicesList+xml' }
          else
            mock_error 200, "401 Unauthorized"
          end
        end

        private

        def generate_internet_services(services)
          builder = Builder::XmlMarkup.new

          builder.InternetServices("xmlns" => "urn:tmrk:eCloudExtensions-2.5", "xmlns:i" => "http://www.w3.org/2001/XMLSchema-instance") {|xml|
            services.each do |service|
              generate_internet_service(xml, service)
            end
          }
        end

        def generate_internet_service(xml, service, by_itself = false)
          xml.InternetService(by_itself ? { "xmlns" => "urn:tmrk:eCloudExtensions-2.5", "xmlns:i" => "http://www.w3.org/2001/XMLSchema-instance" } : {}) {
            xml.Id service.object_id
            xml.Href service.href
            xml.Name service.name
            if MockDataClasses::MockBackupInternetService === service
              xml.PublicIpAddress "i:nil" => true
            else
              xml.PublicIpAddress {
                xml.Id service._parent._parent.object_id
                xml.Href service._parent._parent.href
                xml.Name service._parent._parent.name
              }
            end
            xml.Port service.port
            xml.Protocol service.protocol
            xml.Enabled service.enabled
            xml.Timeout service.timeout
            xml.Description service.description
            xml.RedirectURL service.redirect_url
            xml.Monitor "i:nil" => true
            xml.IsBackupService MockDataClasses::MockBackupInternetService === service
            if MockDataClasses::MockPublicIpInternetService === service && service.backup_service
              xml.BackupService do
                xml.Href service.backup_service.href
              end
            else
              xml.BackupService "i:nil" => true
            end
            xml.BackupOf
          }
        end
      end
    end
  end
end
