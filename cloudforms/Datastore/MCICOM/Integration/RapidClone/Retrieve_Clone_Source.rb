###################################
#
# EVM Automate Method: Retrieve_Clone_Source
#
# Notes: Populate Clone Source
#
###################################
begin
  # Turn of verbose logging
  @debug = true

  @action = nil
  @action ||= $evm.object['action']

  @method = 'Retrieve_Clone_Source'
  $evm.log("info", "#{@method}: #{@action} - EVM Automate Method Started")

  vm = $evm.root['vm']

  @vm_name = vm.attributes['name']
  $evm.log("info", "===== EVM Automate Method: <#{@method}>: #{@action} vm_name: #{@vm_name}")

  @vm_ems_ref = vm.attributes['ems_ref']
  $evm.log("info", "===== EVM Automate Method: <#{@method}>: #{@action} vm_ems_ref: #{@vm_ems_ref}")

  @vm_location = vm.attributes['location']
  $evm.log("info", "===== EVM Automate Method: <#{@method}>: #{@action} vm_location: #{@vm_location}")

  @vm_v_storage_name = vm.storage_name
  $evm.log("info", "===== EVM Automate Method: <#{@method}>: #{@action} vm_v_storage_name: #{@vm_v_storage_name}")

  dialog_clone_source = "VirtualMachine:#{@vm_ems_ref}"
  $evm.log("info", "===== EVM Automate Method: <#{@method}>: #{@action} dialog_clone_source: #{dialog_clone_source}")

  dialog_clone_source_path = "[#{@vm_v_storage_name}]#{@vm_location}"
  $evm.log("info", "===== EVM Automate Method: <#{@method}>: #{@action} dialog_clone_source_path: #{dialog_clone_source_path}")

  case @action
    when "clone_source"
      list_values = {
          'sort_by' => :none,
          'data_type' => :string,
          'required' => :true,
          'values' => [[nil,nil],["#{@vm_name}", "#{dialog_clone_source}"]],
      }

      $evm.log("info", "===== EVM Automate Method: <#{@method}>: #{@action} display drop-down: #{list_values}")
      list_values.each {|k,v| $evm.object[k] = v }

    when "clone_source_path"
      list_values = {
          'sort_by' => :none,
          'data_type' => :string,
          'required' => :true,
          'values' => [[nil,nil],["#{dialog_clone_source_path}", "#{dialog_clone_source_path}"]],
      }
      $evm.log("info", "===== EVM Automate Method: <#{@method}>: #{@action} display drop-down: #{list_values}")
      list_values.each {|k,v| $evm.object[k] = v }

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