###################################
#
# EVM Automate Method: Execute_Rapid_Clone
#
#
#
###################################
begin
  @method = 'Execute_Rapid_Clone'
  $evm.log("info", "===== EVM Automate Method: <#{@method}> Started")

  #########################
  #
  # Method: dumpRoot
  # Description: Dump Root information
  #
  ##########################
  def dumpRoot
    $evm.log("info", "#{@method} - Root:<$evm.root> Begin Attributes")
    $evm.root.attributes.sort.each { |k, v| $evm.log("info", "#{@method} - Root:<$evm.root> Attributes - #{k}: #{v}")}
    $evm.log("info", "#{@method} - Root:<$evm.root> End Attributes")
    $evm.log("info", "")
  end

  # dump root object attributes
  dumpRoot

  require 'savon'
  require 'nokogiri'
  require 'httpclient'
  HTTPI.adapter = :httpclient

  @servername = nil
  @servername ||= $evm.object['servername']

  @username = nil
  @username ||= $evm.object['username']

  @password = nil
  @password ||= $evm.object.decrypt('password')

  @netapp_url = "https://#{@servername.to_s}:8143/kamino/public/api?wsdl"

  vm = $evm.root['vm']

  @vm_name = vm.attributes['name']
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_name: #{@vm_name}")

  @vm_location = vm.attributes['location']
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_location: #{@vm_location}")

  @vm_vendor = vm.attributes['vendor']
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_vendor: #{@vm_vendor}")

  @vm_host_id = vm.attributes['host_id']
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_host_id: #{@vm_host_id}")

  @vm_ems_ref = vm.attributes['ems_ref']
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_ems_ref: #{@vm_ems_ref}")

  @vm_type = vm.attributes['type']
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_type: #{@vm_type}")

  @vm_storage_name = vm.storage['name']
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_storage_name: #{@vm_storage_name}")

  @vm_storage_ems_ref = vm.storage['ems_ref']
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_storage_ems_ref: #{@vm_storage_ems_ref}")

  @vm_v_ems_cluster_name = vm.ems_cluster_name
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_v_ems_cluster_name: #{@vm_v_ems_cluster_name}")

  @vm_v_parent_blue_folder_1_name = vm.parent_blue_folder_1_name
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_v_parent_blue_folder_1_name: #{@vm_v_parent_blue_folder_1_name}")

  @vm_v_parent_blue_folder_2_name = vm.parent_blue_folder_2_name
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_v_parent_blue_folder_2_name: #{@vm_v_parent_blue_folder_2_name}")

  @vm_v_parent_blue_folder_3_name = vm.parent_blue_folder_3_name
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_v_parent_blue_folder_3_name: #{@vm_v_parent_blue_folder_3_name}")

  @vm_v_parent_blue_folder_4_name = vm.parent_blue_folder_4_name
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_v_parent_blue_folder_4_name: #{@vm_v_parent_blue_folder_4_name}")

  @vm_v_parent_blue_folder_5_name = vm.parent_blue_folder_5_name
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_v_parent_blue_folder_5_name: #{@vm_v_parent_blue_folder_5_name}")

  @vm_v_parent_blue_folder_6_name = vm.parent_blue_folder_6_name
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_v_parent_blue_folder_6_name: #{@vm_v_parent_blue_folder_6_name}")

  @vm_v_parent_blue_folder_7_name = vm.parent_blue_folder_7_name
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_v_parent_blue_folder_7_name: #{@vm_v_parent_blue_folder_7_name}")


  @vm_v_parent_blue_folder_8_name = vm.parent_blue_folder_8_name
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_v_parent_blue_folder_8_name: #{@vm_v_parent_blue_folder_8_name}")

  @vm_v_owning_datacenter = vm.v_owning_datacenter
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_v_owning_datacenter: #{@vm_v_owning_datacenter}")



  @vm_v_parent_blue_folder_9_name = vm.parent_blue_folder_9_name
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_v_parent_blue_folder_9_name: #{@vm_v_parent_blue_folder_9_name}")

  @vm_v_storage_name = vm.storage_name
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_v_storage_name: #{@vm_v_storage_name}")

  def getObjectRef(netapp_url, servername, username, password, arg_name, arg_type)
    Savon.configure do |config|
#      config.log = false
#      config.log_level = :info
      config.pretty_print_xml = true
    end
    client = Savon::Client.new do |wsdl, http, wsse|
      wsdl.document = "#{netapp_url}"
      wsdl.endpoint = "#{netapp_url}"
      http.auth.ssl.verify_mode = :none
    end
    response = client.request "ser:getMoref" do
      soap.namespaces.merge!({
                                 "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/",
                                 "xmlns:ser" => "http://server.kamino.netapp.com/"
                             })
      soap.header = {}
      soap.body = { 'arg0' => "#{arg_name}", 'arg1' => "#{arg_type}", 'arg2' => { 'serviceUrl' => "https://#{servername.to_s}/sdk", 'vcPassword' => "#{password.to_s}", 'vcUser' => "#{username.to_s}" } }
    end
    response_hash = response.to_hash[:get_moref_response]
    ref_obj = "#{response_hash[:return]}"
    return ref_obj
  end

#  @vm_object = getObjectRef(@netapp_url, @servername, @username, @password, "#{@vm_name}", "VirtualMachine")
#  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_object: #{@vm_object.inspect}")

  @vm_object = getObjectRef(@netapp_url, @servername, @username, @password, "#{@vm_name}", "VirtualMachine")
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_object: #{@vm_object.inspect}")

  dialog_clone_destination = getObjectRef(@netapp_url, @servername, @username, @password, "#{@vm_v_owning_datacenter}", "Datacenter")
  $evm.log("info", "===== EVM Automate Method: <#{@method}> dialog_clone_destination: #{dialog_clone_destination}")

#  @dialog_clone_destination = getObjectRef(@netapp_url, @servername, @username, @password, "#{@vm_v_ems_cluster_name}", "Cluster")
#  $evm.log("info", "===== EVM Automate Method: <#{@method}> dialog_clone_destination: #{@dialog_clone_destination.inspect}")


  controller_ip = nil
  controller_ip ||= $evm.object['controller_ip']

  controller_username = nil
  controller_username ||= $evm.object['controller_username']

  controller_password = nil
  controller_password ||= $evm.object.decrypt('controller_password')

  dialog_clone_name = $evm.root.attributes['dialog_clone_name']

  if $evm.root.attributes['dialog_clone_name'] == 1
    dialog_power_on = 'true'
  else
    dialog_power_on = 'false'
  end

  #dialog_clone_destination = 'Cluster:domain-c121'
  dialog_datastore_selection = "Datastore:#{@vm_storage_ems_ref}"
  dialog_clone_source_path = $evm.root.attributes['dialog_clone_source_path']
  $evm.log("info", "===== EVM Automate Method: <#{@method}> dialog_clone_source_path: #{dialog_clone_source_path}")
  dialog_clone_source = $evm.root.attributes['dialog_clone_source']
  $evm.log("info", "===== EVM Automate Method: <#{@method}> dialog_clone_source: #{dialog_clone_source}")
  dialog_vm_cpu = $evm.root.attributes['dialog_vm_cpu']
  dialog_memory_size = $evm.root.attributes['dialog_memory_size']

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
      xml.serviceUrl "https://#{@servername.to_s}/sdk"
      xml.vcPassword "#{@password.to_s}"
      xml.vcUser "#{@username.to_s}"
    }
  end

  puts builder.to_xml

  connectapi = Savon::Client.new do |wsdl, http, wsse|
    wsdl.document = "#{@netapp_url}"
    wsdl.endpoint = "#{@netapp_url}"
    http.auth.ssl.verify_mode = :none
  end

  response = connectapi.request "ser:createClones" do
    soap.namespaces.merge!({
         "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/",
         "xmlns:ser" => "http://server.kamino.netapp.com/"
     })
    soap.header = {}
    soap.body = builder.doc.root.to_xml
  end

  response_hash = response.to_hash

  $evm.log("info", "===== EVM Automate Method: <#{@method}> #{response_hash.inspect}")

  #
  # Exit method
  #
  $evm.log("info", "===== EVM Automate Method: <#{@method}> Ended")
  exit MIQ_OK

    #
    # Set Ruby rescue behavior
    #
rescue => err
  $evm.log("error", "<#{@method}>: [#{err}]\n#{err.backtrace.join("\n")}")
  exit MIQ_STOP
end