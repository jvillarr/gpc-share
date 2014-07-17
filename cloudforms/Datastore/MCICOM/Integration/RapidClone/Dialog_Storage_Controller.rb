###################################
#
# EVM Automate Method: Dialog_Storage_Controller
#
# Notes: Populate Dialog_Storage_Controller
#
###################################
begin
  @method = 'Dialog_Storage_Controller'
  $evm.log("info", "#{@method} - EVM Automate Method Started")

  # Turn of verbose logging
  @debug = true

  dialog_hash = { "netapp02a (Default)" => "10.2.100.19", "netapp02a" => "10.2.100.19", "netapp02b" => "10.2.100.20", "netapp03a" => "10.2.100.21" }
  dialog_field = $evm.object
  dialog_field["sort_by"] = "none"
  dialog_field["data_type"] = "string"
  dialog_field["required"] = "true"
  dialog_field["values"] = dialog_hash
  dialog_field["default_value"] = "netapp02a"

  $evm.log("info", "===== EVM Automate Method: <#{@method}> display drop-down: #{dialog_hash.inspect}")

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