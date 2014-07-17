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

  # Turn of verbose logging
  @debug = true

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