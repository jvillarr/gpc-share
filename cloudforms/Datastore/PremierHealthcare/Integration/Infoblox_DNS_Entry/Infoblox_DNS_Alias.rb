###################################
#
# EVM Automate Method: Infoblox_DNS_Alias
#
# Notes: EVM Automate method to add Host entry to Infoblox
#
###################################
begin
  @method = 'Infoblox_DNS_Alias'
  $evm.log("info", "===== EVM Automate Method: <#{@method}> Started")

  # Turn of verbose logging
  @debug = true

  require 'rest_client'
  require 'json'
  require 'nokogiri'
  require 'ipaddr'

  ##################################
  # Dump Root Vars                 #
  ##################################
  def dump_root()
    $evm.log("info", "Root:<$evm.root> Begin $evm.root.attributes")
    $evm.root.attributes.sort.each { |k, v| $evm.log("info", "Root:<$evm.root> Attribute - #{k}: #{v}")}
    $evm.log("info", "Root:<$evm.root> End $evm.root.attributes")
    $evm.log("info", "")
  end

  ##################################
  # Add DNS Alias                  #
  ##################################
  def addAlias(cname, canonical)
    begin
      url = 'https://' + @connection + '/wapi/v1.0/record:cname'
      content = "\{\"name\":\"#{cname}\",\"canonical\":\"#{canonical}\"\}"
      dooie = RestClient.post url, content, :content_type => :json, :accept => :json
      $evm.log("info", "===== EVM Automate Method: <#{@method}> Add Alias inspect: #{dooie.inspect}")
      return true
    rescue Exception => e
      puts e.inspect
      return false
    end
  end

  ###########################################
  # Testing                                 #
  ###########################################

  # dump all root attributes to the log
  dump_root

  vm = $evm.root['vm']

  username = nil
  username ||= $evm.object['username']

  password = nil
  password ||= $evm.object.decrypt('password')

  servername = nil
  servername ||= $evm.object['servername']

  dnsdomain = nil
  dnsdomain ||= $evm.object['domain']

  dialog_cname = $evm.root.attributes['dialog_cname'] || nil

  @name =  "#{vm['name']}.#{dnsdomain}"

  @connection = "#{username}:#{password}@#{servername}"

  uooie = addAlias("#{dialog_cname}.#{dnsdomain}","#{@name}")
  if uooie ==  true
    $evm.log("info", "===== EVM Automate Method: <#{@method}> Success: #{dialog_cname}.#{dnsdomain} to forward to #{@name}")
  else
    $evm.log("info", "===== EVM Automate Method: <#{@method}> FAIL: to add DNS Alias of #{dialog_cname}.#{dnsdomain} to forward to #{@name}")
    exit MIQ_ABORT
  end

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
  exit MIQ_ABORT
end