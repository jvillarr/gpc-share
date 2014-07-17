###################################
#
# EVM Automate Method: Dialog_VM_Sizing
#
# Notes: Populate Dialog_VM_Sizing CPU and Memory
#
###################################
begin
  @method = 'Dialog_VM_Sizing'
  $evm.log("info", "#{@method} - EVM Automate Method Started")

  # Turn of verbose logging
  @debug = true

  @action = nil
  @action ||= $evm.object['action']

  vm = $evm.root['vm']

  @vm_memory_cpu = vm.hardware['memory_cpu']
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_memory_cpu: #{@vm_memory_cpu}")

  @vm_numvcpus = vm.hardware['numvcpus']
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_numvcpus: #{@vm_numvcpus}")

  case @action
    when "memory"
      mem_val = 1024
      vm_mem = @vm_memory_cpu.to_i / 1024
      mem_array = []
      default_val = [nil,nil]
      mem_array << default_val
      for n in 1..16
        $evm.log("info", "===== EVM Automate Method: <#{@method}> mem_val: #{mem_val}, mem_array: #{mem_array}")
        val = []
        val << "#{n}"
        val << mem_val.to_i
        mem_array << val
        mem_val = mem_val.to_i + 1024
      end
      list_values = {
          'sort_by' => :none,
          'data_type' => :string,
          'required' => :true,
          'values' => mem_array
      }

      $evm.log("info", "===== EVM Automate Method: <#{@method}> display drop-down: #{list_values}")
      list_values.each {|k,v| $evm.object[k] = v }

    when "cpu"
      cpu_array = []
      default_val = [nil,nil]
      cpu_array << default_val
      for n in 1..12
        val = []
        val << n
        val << n
        cpu_array << val
      end

      list_values = {
          'sort_by' => :none,
          'data_type' => :integer,
          'required' => :true,
          'values' => cpu_array
      }
      $evm.log("info", "===== EVM Automate Method: <#{@method}> display drop-down: #{list_values}")
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