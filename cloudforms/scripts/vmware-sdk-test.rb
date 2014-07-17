require 'savon'
require 'nokogiri'
require 'httpclient'
HTTPI.adapter = :httpclient

servername = 'mcimgmt1.mcis.usmc.mil'
username = 'MCIS\jose'
password = 'Password1234!@#$'

controller_ip = '10.2.100.19'
controller_username = 'vsc.netapp.svc'
controller_password = '1wdv!WDV4esz$ESZ'

dialog_clone_name = 'cfme-test-api1'
dialog_power_on = 'false'
dialog_clone_destination = 'Datacenter:datacenter-2'
dialog_datastore_selection = 'Datastore:datastore-66'
dialog_clone_source_path = '[cage2_nfs_data2]w2k8-jump-template-20140506/w2k8-jump-template-20140506.vmx'
dialog_clone_source = 'VirtualMachine:vm-14761'

namespaces = {
    "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/",
    "xmlns:ser" => "http://server.kamino.netapp.com/"
}

builder = Nokogiri::XML::Builder.new do |xml|
  xml.arg0 {
    xml.cloneSpec {
      xml.clones {
        xml.entry {
          xml.key "#{dialog_clone_name.to_s}"
          xml.value {
            xml.powerOn "#{dialog_power_on.to_s}"
          }
        }
      }
      xml.containerMoref "#{dialog_clone_destination.to_s}"
      xml.files {
        xml.destDatastoreSpec {
          xml.controller {
            xml.ipAddress "#{controller_ip.to_s}"
            xml.password "#{controller_password.to_s}"
            xml.ssl "false"
            xml.username "#{controller_username.to_s}"
          }
          xml.mor "#{dialog_datastore_selection.to_s}"
          xml.numDatastores "0"
          xml.thinProvision "false"
          xml.volAutoGrow "false"
        }
        xml.sourcePath "#{dialog_clone_source_path.to_s}"
      }
      xml.templateMoref "#{dialog_clone_source.to_s}"
    }
    xml.serviceUrl "https://#{servername.to_s}/sdk"
    xml.vcPassword "#{password.to_s}"
    xml.vcUser "#{username.to_s}"
  }
end
puts builder.to_xml


client = Savon::Client.new do |wsdl, http, wsse|
  wsdl.document = "https://#{servername.to_s}:8143/kamino/public/api?wsdl"
  wsdl.endpoint = "https://#{servername.to_s}:8143/kamino/public/api?wsdl"
  http.auth.ssl.verify_mode = :none
end

response = client.request "ser:createClones" do
  soap.namespaces.merge!({
                             "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/",
                             "xmlns:ser" => "http://server.kamino.netapp.com/"
                         })
  soap.header = {}
  soap.body = builder.doc.root.to_xml
end

response_hash = response.to_hash

puts response_hash.inspect
