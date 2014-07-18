###################################
    #
    # EVM Automate Method: Dialog_Destination_Folder
    #
    # Notes: Dialog_Destination_Folder
    #
    ###################################
begin
  @method = 'Dialog_Destination_Folder'
  $evm.log("info", "#{@method} - EVM Automate Method Started")

  # Turn of verbose logging
  @debug = true

  vm = $evm.root['vm']
  ems = vm.ext_management_system
  folder_array = []
  folder_array << [nil,nil]
  folders = ems.ems_folders.each {|ef|
    val = []
   # $evm.log("info", "#{@method} - #{ef.inspect}")
    if ef.is_datacenter == false && ef.name != "Datacenters" && ef.name != "host" && ef.name != "vm"
      val << "#{ef.name}"
      val << "#{ef.ems_ref}"
      folder_array << val
    end
  }

  list_values = {
      'sort_by' => :none,
      'data_type' => :string,
      'required' => :false,
      'values' => folder_array
  }

  $evm.log("info", "===== EVM Automate Method: <#{@method}> display drop-down: #{list_values}")
  list_values.each {|k,v| $evm.object[k] = v }

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
