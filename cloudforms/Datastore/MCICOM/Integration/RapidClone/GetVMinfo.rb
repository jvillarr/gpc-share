###################################
#
# EVM Automate Method: GetVMinfo
#
# Notes: Dump the objects in storage to the automation.log
#
###################################
begin
  @method = 'GetVMinfo'
  $evm.log("info", "#{@method} - EVM Automate Method Started")

  #########################
  # add required gems
  ##########################
  require 'savon'
  require 'nokogiri'
  require 'httpclient'
  HTTPI.adapter = :httpclient

  # Turn of verbose logging
  @debug = true

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


  @vm_memory_cpu = vm.hardware['memory_cpu']
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_memory_cpu: #{@vm_memory_cpu}")


  @vm_numvcpus = vm.hardware['numvcpus']
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_numvcpus: #{@vm_numvcpus}")


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


  @vm_v_parent_blue_folder_9_name = vm.parent_blue_folder_9_name
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_v_parent_blue_folder_9_name: #{@vm_v_parent_blue_folder_9_name}")


  @vm_v_storage_name = vm.storage_name
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_v_storage_name: #{@vm_v_storage_name}")


  dialog_vm_snapshots = {}
  if vm.v_total_snapshots > 0
    vm.snapshots.each do |ss|
      dialog_vm_snapshots[ss.ems_ref] = "#{ss.name}"
    end
    $evm.log("info","========= VM Snapshot Name: #{dialog_vm_snapshots.inspect}")
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
      config.log_level = :info
      config.pretty_print_xml = true
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
    file_hash = {}
    response_hash[:return].each { |k|
      source_path = k[:source_path].to_s
      file_hash['source_path'] = source_path
      $evm.log("info", "===== EVM Automate Method: <#{@method}> k[:source_path].inspect: #{k[:source_path].inspect}")

      mor = k[:dest_datastore_spec][:mor].to_s
      file_hash['mor'] = mor
      $evm.log("info", "===== EVM Automate Method: <#{@method}> k[:dest_datastore_spec][:mor].inspect: #{k[:dest_datastore_spec][:mor].inspect}")
      file_array << file_hash
    }

    return file_array
  end

  #########################
  # Get VMware object References
  ##########################
  @vm_files = getVmFiles(@netapp_url, @servername, @username, @password, "VirtualMachine:#{@vm_ems_ref}")
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_files: #{@vm_files.inspect}")

  #
  # Exit method
  #
  $evm.log("info", "#{@method} - EVM Automate Method Ended")
  exit MIQ_OK

    #
    # Set Ruby rescue behavior
    #
rescue => err
  $evm.log("error", "#{@method} - [#{err}]\n#{err.backtrace.join("\n")}")
  exit MIQ_ABORT
end