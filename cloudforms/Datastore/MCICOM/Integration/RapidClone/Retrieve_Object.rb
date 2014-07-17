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
  require 'httpclient'
  HTTPI.adapter = :httpclient
  HTTPI.log = false

  @servername = 'mcimgmt1.mcis.usmc.mil'
  @username = 'MCIS\jose'
  @password = 'Password1234!@#$'

  def getObjectRef(servername, username, password, arg_name, arg_type)
    Savon.configure do |config|
      config.log = false
      config.log_level = :info
      config.pretty_print_xml = true
    end

    client = Savon::Client.new do |wsdl, http, wsse|
      wsdl.document = "https://#{@servername.to_s}:8143/kamino/public/api?wsdl"
      wsdl.endpoint = "https://#{@servername.to_s}:8143/kamino/public/api?wsdl"
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

  vm_object = getObjectRef(@servername, @username, @password, "w2k8r2-jump-template-20140506", "VirtualMachine")
  $evm.log("info", "===== EVM Automate Method: <#{@method}> vm_object: #{vm_object.inspect}")

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