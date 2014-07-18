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
  # Method: dumpRoot
  # Description: Dump Root information
  ##########################
  def dumpRoot
    $evm.log("info", "#{@method} - Root:<$evm.root> Begin Attributes")
    $evm.root.attributes.sort.each { |k, v| $evm.log("info", "#{@method} - Root:<$evm.root> Attributes - #{k}: #{v}")}
    $evm.log("info", "#{@method} - Root:<$evm.root> End Attributes")
    $evm.log("info", "")
  end

  # dump root object attributes
  dumpRoot

  #########################
  # add required gems
  ##########################
  require 'savon'
  require 'nokogiri'
  require 'httpclient'
  HTTPI.adapter = :httpclient

  #########################
  # Gather up instance object variables
  ##########################
  @servername = nil
  @servername ||= $evm.object['servername']

  @username = nil
  @username ||= $evm.object['username']

  @password = nil
  @password ||= $evm.object.decrypt('password')

  controller_ip = nil
  controller_ip ||= $evm.object['controller_ip']

  controller_username = nil
  controller_username ||= $evm.object['controller_username']

  controller_password = nil
  controller_password ||= $evm.object.decrypt('controller_password')

  @netapp_url = "https://#{@servername.to_s}:8143/kamino/public/api?wsdl"

  #########################
  # Gather up VM object variables
  ##########################
  vm = $evm.root['vm']
  @vm_name = vm.attributes['name']
  @vm_location = vm.attributes['location']
  @vm_vendor = vm.attributes['vendor']
  @vm_host_id = vm.attributes['host_id']
  @vm_ems_ref = vm.attributes['ems_ref']
  @vm_type = vm.attributes['type']
  @vm_storage_name = vm.storage['name']
  @vm_storage_ems_ref = vm.storage['ems_ref']
  @vm_v_ems_cluster_name = vm.ems_cluster_name
  @vm_v_parent_blue_folder_1_name = vm.parent_blue_folder_1_name
  $evm.log("info", "===== EVM Automate Method: <#{@method}> @vm_v_parent_blue_folder_1_name.inspect: #{@vm_v_parent_blue_folder_1_name.inspect}")

  @vm_v_parent_blue_folder_2_name = vm.parent_blue_folder_2_name
  $evm.log("info", "===== EVM Automate Method: <#{@method}> @vm_v_parent_blue_folder_2_name.inspect: #{@vm_v_parent_blue_folder_2_name.inspect}")

  @vm_v_parent_blue_folder_3_name = vm.parent_blue_folder_3_name
  $evm.log("info", "===== EVM Automate Method: <#{@method}> @vm_v_parent_blue_folder_3_name.inspect: #{@vm_v_parent_blue_folder_3_name.inspect}")

  @vm_v_parent_blue_folder_4_name = vm.parent_blue_folder_4_name
  @vm_v_parent_blue_folder_5_name = vm.parent_blue_folder_5_name
  @vm_v_parent_blue_folder_6_name = vm.parent_blue_folder_6_name
  @vm_v_parent_blue_folder_7_name = vm.parent_blue_folder_7_name
  @vm_v_parent_blue_folder_8_name = vm.parent_blue_folder_8_name
  @vm_v_owning_datacenter = vm.v_owning_datacenter
  @vm_v_parent_blue_folder_9_name = vm.parent_blue_folder_9_name
  @vm_v_storage_name = vm.storage_name

  #########################
  # Method: getObjectRef
  # Query the NetApp API with real object name to get VMware Object Reference Names
  ##########################
  def getObjectRef(netapp_url, servername, username, password, arg_name, arg_type)
    #########################
    # Savon Configuration
    ##########################
    Savon.configure do |config|
      config.log = false
#      config.log_level = :info
#      config.pretty_print_xml = true
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

  #########################
  # Method: getObjectRef
  # Query the NetApp API with real object name to get VMware Object Reference Names
  ##########################
  def getVmFiles(netapp_url, servername, username, password, arg_name)
    #########################
    # Savon Configuration
    ##########################
    Savon.configure do |config|
      config.log = false
#      config.log_level = :info
#      config.pretty_print_xml = true
    end

    client = Savon::Client.new do |wsdl, http, wsse|
      wsdl.document = "#{netapp_url}"
      wsdl.endpoint = "#{netapp_url}"
      http.auth.ssl.verify_mode = :none
    end
    response = client.request "ser:getVmFiles" do
      soap.namespaces.merge!({
                                 "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/",
                                 "xmlns:ser" => "http://server.kamino.netapp.com/"
                             })
      soap.header = {}
      soap.body = { 'arg0' => "#{arg_name}", 'arg1' => { 'serviceUrl' => "https://#{servername.to_s}/sdk", 'vcPassword' => "#{password.to_s}", 'vcUser' => "#{username.to_s}" } }
    end

    $evm.log("info", "===== EVM Automate Method: <#{@method}> response.to_hash.inspect: #{response.to_hash.inspect}")

    response_hash = response.to_hash[:get_vm_files_response]
    $evm.log("info", "===== EVM Automate Method: <#{@method}> response_hash.inspect: #{response_hash.inspect}")

    file_array = []
    response_hash[:return].each { |v|
      file_hash = {}
      file_hash['source_path'] = v[:source_path].to_s
      file_hash['mor'] =  v[:dest_datastore_spec][:mor].to_s
      file_hash['num_datastores'] =  v[:dest_datastore_spec][:num_datastores].to_s
      file_hash['storage_service'] =  v[:dest_datastore_spec][:storage_service].to_s
      file_hash['thin_provision'] =  v[:dest_datastore_spec][:thin_provision].to_s
      file_hash['vol_auto_grow'] =  v[:dest_datastore_spec][:vol_auto_grow].to_s
      file_hash['wrapper_vol'] =  v[:dest_datastore_spec][:wrapper_vol].to_s
      file_array.push(file_hash)
    }

    $evm.log("info", "===== EVM Automate Method: <#{@method}> file_array.inspect: #{file_array.inspect}")

    return file_array
  end

  #########################
  # Get Source VM Files locations
  ##########################
  @vm_files = getVmFiles(@netapp_url, @servername, @username, @password, "VirtualMachine:#{@vm_ems_ref}")
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_files.inspect: #{@vm_files.inspect}")
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_files.class: #{@vm_files.class}")

  #########################
  # Get VMware object References
  ##########################
  @vm_object = getObjectRef(@netapp_url, @servername, @username, @password, "#{@vm_name}", "VirtualMachine")
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_object: #{@vm_object.inspect}")

  dialog_clone_destination = getObjectRef(@netapp_url, @servername, @username, @password, "#{@vm_v_owning_datacenter}", "Datacenter")
  $evm.log("info", "===== EVM Automate Method: <#{@method}> dialog_clone_destination: #{dialog_clone_destination}")

  dialog_clone_vm_folder = getObjectRef(@netapp_url, @servername, @username, @password, "templates", "Folder")
  $evm.log("info", "===== EVM Automate Method: <#{@method}> dialog_clone_destination: #{dialog_clone_destination}")


  #########################
  # Get vars from dialogs
  ##########################
  dialog_clone_name = $evm.root.attributes['dialog_clone_name']

  if $evm.root.attributes['dialog_clone_name'] == 1
    dialog_power_on = 'true'
  else
    dialog_power_on = 'false'
  end

  dialog_destination_folder = $evm.root.attributes['dialog_destination_folder']
  dialog_vm_cpu = $evm.root.attributes['dialog_vm_cpu']
  dialog_memory_size = $evm.root.attributes['dialog_memory_size']

  dialog_number_of_clones = $evm.root.attributes['dialog_number_of_clones']
  dialog_starting_clone_number = $evm.root.attributes['dialog_starting_clone_number']
  dialog_clone_number_increment = $evm.root.attributes['dialog_clone_number_increment']

  #########################
  # Create XML Message for the API
  ##########################
  builder = Nokogiri::XML::Builder.new do |xml|
    xml.arg0 {
      xml.cloneSpec {
        xml.containerMoref "#{dialog_clone_destination.to_s}"
      }
      xml.serviceUrl "https://#{@servername.to_s}/sdk"
      xml.vcPassword "#{@password.to_s}"
      xml.vcUser "#{@username.to_s}"
    }
  end

  #########################
  # Create Number of Clones entries
  ##########################
  count = 0
  increment = dialog_starting_clone_number.to_i
  while count < dialog_number_of_clones.to_i do
    if dialog_number_of_clones == 1
      clone_name = "#{dialog_clone_name.to_s}"
    else
      clone_name = "#{dialog_clone_name.to_s}#{increment.to_s}"
    end
    clones = Nokogiri::XML::Builder.new do |xml|
      xml.clones {
        xml.entry {
          xml.key "#{clone_name.to_s}"
          xml.value {
            xml.powerOn "#{dialog_power_on.to_s}"
          }
        }
      }
    end
    builder.doc.root.at('cloneSpec').add_child(clones.doc.root)
    count +=1
    increment += dialog_clone_number_increment.to_i
  end

  @vm_files.each { |k|
    $evm.log("info", "===== EVM Automate Method: <#{@method}> @vm_files.each: #{k.inspect}")

    xml_files = Nokogiri::XML::Builder.new do |xml|
      xml.files {
        xml.destDatastoreSpec {
          xml.controller {
            xml.ipAddress "#{controller_ip.to_s}"
            xml.password "#{controller_password.to_s}"
            xml.ssl "false"
            xml.username "#{controller_username.to_s}"
          }
          xml.mor "#{k['mor'].to_s}"
          xml.numDatastores k['num_datastores'].to_s
          xml.thinProvision k['thin_provision'].to_s
          xml.volAutoGrow k['vol_auto_grow'].to_s
          xml.wrapperVol k['wrapper_vol'].to_s
        }
        xml.sourcePath "#{k['source_path'].to_s}"
      }
    end

    # Add this files section to the the end of cloneSpec
    builder.doc.root.at('cloneSpec').add_child(xml_files.doc.root)
  }

  unless dialog_destination_folder.nil?
    # Add Destination Folder to the the end of cloneSpec
    destVmFolderMoref = Nokogiri::XML::Builder.new do |xml|
      xml.destVmFolderMoref "Folder:#{dialog_destination_folder.to_s}"
    end
    builder.doc.root.at('cloneSpec').add_child(destVmFolderMoref.doc.root)
  end

  # Add numberCPU to the the end of cloneSpec
  numberCPU = Nokogiri::XML::Builder.new do |xml|
    xml.numberCPU dialog_vm_cpu.to_s
  end
  builder.doc.root.at('cloneSpec').add_child(numberCPU.doc.root)

  # Add Memory to the the end of cloneSpec
  memMB = Nokogiri::XML::Builder.new do |xml|
    xml.memMB dialog_memory_size.to_s
  end
  builder.doc.root.at('cloneSpec').add_child(memMB.doc.root)

  # Add templateMoref to the the end of cloneSpec
  templateMoref = Nokogiri::XML::Builder.new do |xml|
    xml.templateMoref "#{@vm_object.to_s}"
  end
  builder.doc.root.at('cloneSpec').add_child(templateMoref.doc.root)

  #########################
  # Setup client connection to API
  ##########################
  client = Savon::Client.new do |wsdl, http, wsse|
    wsdl.document = "#{@netapp_url}"
    wsdl.endpoint = "#{@netapp_url}"
    http.auth.ssl.verify_mode = :none
  end

  #########################
  # Send message to API
  ##########################
  response = client.request "ser:createClones" do
    soap.namespaces.merge!({
                               "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/",
                               "xmlns:ser" => "http://server.kamino.netapp.com/"
                           })
    soap.header = {}
    soap.body = builder.doc.root.to_xml
  end

  #########################
  # Convert response to hash
  ##########################
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