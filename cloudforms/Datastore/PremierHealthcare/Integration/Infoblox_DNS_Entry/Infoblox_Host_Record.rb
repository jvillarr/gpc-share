###################################
#
# EVM Automate Method: Infoblox_Host_Record
#
# Notes: EVM Automate method to add Host entry to Infoblox
#
###################################
begin
  @method = 'Infoblox_Host_Record'
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
  # Fetch Host                     #
  ##################################
  def fetchHost(host)
    begin
      url = 'https://' + @connection + '/wapi/v1.0/record:host?' + "name=#{host}"
      $evm.log("info", "============== #{url.inspect}")
      dooie = RestClient.get url
      $evm.log("info", "============== #{dooie.inspect}")
      doc = Nokogiri::XML(dooie)
      root = doc.root
      hosts = root.xpath("value/_ref/text()")
      hosts.each do | a |
        a = a.to_s
        unless a.index(host).nil?
          puts "Host Found - #{a}"
          return a
        end
      end
      return true
    rescue Exception => e
      puts e.inspect
      return false
    end
  end

  ##################################
  # Delete Host                    #
  ##################################
  def deleteHost(item)
    begin
      url = 'https://' + @connection + '/wapi/v1.0/' + item
      dooie = RestClient.delete url
      return true
    rescue Exception => e
      puts e.inspect
      return false
    end
  end

  ##################################
  # Get IP Address                 #
  ##################################
  def getIP(hostname, ipaddress)
    begin
      url = 'https://' + @connection + '/wapi/v1.0/record:host'
      content = "\{\"ipv4addrs\":\[\{\"ipv4addr\":\"#{ipaddress}\"\}\],\"name\":\"#{hostname}\"\}"
      dooie = RestClient.post url, content, :content_type => :json, :accept => :json
      return true
    rescue Exception => e
      puts e.inspect
      return false
    end
  end

  ##################################
  # Fetch Network Ref              #
  ##################################
  def fetchNetworkRef(cdir)
    begin
      $evm.log("info","GetIP --> Network Search - #{cdir}")
      url = 'https://' + @connection + '/wapi/v1.0/network'
      dooie = RestClient.get url
      doc = Nokogiri::XML(dooie)
      root = doc.root
      networks = root.xpath("value/_ref/text()")
      networks.each do | a |
        a = a.to_s
        unless a.index(cdir).nil?
          $evm.log("info", "===== EVM Automate Method: <#{@method}> GetIP --> Network Found - #{a}")
          return a
        end
      end
      return nil
    rescue Exception => e
      $evm.log("info", "===== EVM Automate Method: <#{@method}> #{e.inspect}")
      return false
    end
  end

  ##################################
  # Next Available IP Address      #
  ##################################
    def nextIP(network)
      begin
        $evm.log("info","NextIP on - #{network}")
        url = 'https://' + @connection + '/wapi/v1.0/' + network
        dooie = RestClient.post url, :_function => 'next_available_ip', :num => '1'
        doc = Nokogiri::XML(dooie)
        root = doc.root
        nextip = root.xpath("ips/list/value/text()")
        $evm.log("info", "===== EVM Automate Method: <#{@method}> NextIP is - #{nextip}")
        return nextip
      rescue Exception => e
        $evm.log("info", "===== EVM Automate Method: <#{@method}> #{e.inspect}")
        return false
      end
    end

  ############################
  #
  # Method: validate_ipaddr
  # Notes: This method uses a regular expression to validate the ipaddr and gateway
  # Returns: Returns string: true/false
  #
  ############################
  def validate_ipaddr(ip)
    ip_regex = /\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/
    if ip_regex =~ ip
      $evm.log("info","IP Address:<#{ip}> passed validation") if @debug
      return true
    else
      $evm.log("error","IP Address:<#{ip}> failed validation") if @debug
      return false
    end
  end

  ##################################
  # Set Options in prov                                       #
  ##################################
  def set_prov(prov, hostname, ipaddr, netmask, gateway)
    $evm.log("info", "GetIP --> Hostname = #{hostname}")
    $evm.log("info", "GetIP --> IP Address =  #{ipaddr}")
    $evm.log("info", "GetIP -->  Netmask = #{netmask}")
    $evm.log("info", "GetIP -->  Gateway = #{gateway}")
    prov.set_option(:sysprep_spec_override, 'true')
    prov.set_option(:addr_mode, ["static", "Static"])
    prov.set_option(:ip_addr, "#{ipaddr}")
    prov.set_option(:subnet_mask, "#{netmask}")
    prov.set_option(:gateway, "#{gateway}")
    prov.set_option(:vm_target_name, "#{hostname}")
    prov.set_option(:linux_host_name, "#{hostname}")
    prov.set_option(:vm_target_hostname, "#{hostname}")
    prov.set_option(:host_name, "#{hostname}")
    $evm.log("info", "GetIP --> #{prov.inspect}")
    $evm.log("info", "GetIP --> #{prov.get_option(:ip_addr)}")

  end

  ##################################
  # Set netmask                        #
  ##################################
  def netmask(cdir)
    netblock = IPAddr.new(cdir)
    netins =  netblock.inspect
    netmask = netins.match(/(?<=\/)(.*?)(?=\>)/)
    $evm.log("info", "GetIP --> Netmask = #{netmask}")
    return netmask
  end

  ###########################################
  # Testing                                 #
  ###########################################


  # dump all root attributes to the log
  dump_root

  action = nil
  action ||= $evm.object['action'] || $evm.root['action']
  $evm.log("info","GetIP --> Action= #{action}")

  username = nil
  username ||= $evm.object['username']

  password = nil
  password ||= $evm.object.decrypt('password')

  servername = nil
  servername ||= $evm.object['servername']

  subnet = nil
  subnet ||= $evm.object['subnet']

  gateway = nil
  gateway ||= $evm.object['gateway']

  dnsdomain = nil
  dnsdomain ||= $evm.object['domain']

  #  Get vm from miq_provision object
  prov = $evm.root["miq_provision"]
  $evm.log("info","#{prov.inspect}")

  vm_name = prov.options[:vm_target_name]
  $evm.log("info","GetIP --> VM Name = #{vm_name}")

  vm_dest_id = prov['destination_id'].to_i
  $evm.log("info","GetIP --> vm_dest_id = #{vm_dest_id.inspect}")

  vm_data = $evm.vmdb('vm', vm_dest_id) unless vm_dest_id == 0
  $evm.log("info","GetIP --> vm_data = #{vm_data.inspect}")

  ipaddress = vm_data.ipaddresses[0]
  $evm.log("info","GetIP --> IP Address = #{ipaddress}")

  @name =  "#{vm_name}.#{dnsdomain}"
  raise "VM Name was not passed" if @name.empty?

  @connection = "#{username}:#{password}@#{servername}"

  if vm_data['vendor'] == 'openstack'
    $evm.log("info", "===== EVM Automate Method: <#{@method}> Vendor Type: #{vm_data['vendor']} Running Infoblox Integration")
    case action

      when "verifyhost"
        $evm.log("info", "===== EVM Automate Method: <#{@method}> Verifying Host: #{@name}.#{dnsdomain}")
        sooie = fetchHost("#{@name}.#{dnsdomain}")
        if sooie ==  true
          $evm.log("info", "===== EVM Automate Method: <#{@method}> Host: #{@name}.#{dnsdomain} does NOT exist")
        else
          $evm.log("info", "===== EVM Automate Method: <#{@method}> Host: #{@name}.#{dnsdomain} does exist")
        end

      when "createhost"
        ipadd = '10.32.18.55'
        $evm.log("info", "===== EVM Automate Method: <#{@method}> IPADD: #{ipadd.inspect} #{ipadd.class} -> IPADDRESS #{ipaddress.inspect} #{ipaddress.class}")
        uooie = getIP("#{@name}.#{dnsdomain}","#{ipaddress}")
        if uooie ==  true
          $evm.log("info", "===== EVM Automate Method: <#{@method}> #{@name}.#{dnsdomain} with IP Address #{ipaddress} created successfully")
        elsif uooie == false
          $evm.log("info", "===== EVM Automate Method: <#{@method}> #{@name}.#{dnsdomain} with IP Address #{ipaddress} FAILED")
          exit MIQ_ABORT
        else
          $evm.log("info", "===== EVM Automate Method: <#{@method}> unknown error")
          exit MIQ_ABORT
        end

      when "getipnext"
        netRef = fetchNetworkRef(subnet)
        nextIPADDR = nextIP(netRef)
        $evm.log("info", "===== EVM Automate Method: <#{@method}> GetIPNext-before --> #{prov.options[:vm_target_name]}.#{dnsdomain} with IP Address #{nextIPADDR} created successfully")
        result = getIP("#{prov.options[:vm_target_name]}.#{dnsdomain}", nextIPADDR)
        $evm.log("info", "===== EVM Automate Method: <#{@method}> GetIPNext-after --> #{prov.options[:vm_target_name]}.#{dnsdomain} with IP Address #{nextIPADDR} created successfully")
        if result ==  true
          $evm.log("info", "===== EVM Automate Method: <#{@method}> GetIP --> #{prov.options[:vm_target_name]}.#{dnsdomain} with IP Address #{nextIPADDR} created successfully")
          netmask = netmask(subnet)
          set_prov(prov, prov.options[:vm_target_name], nextIPADDR, netmask, gateway)
        elsif result == false
          $evm.log("info", "===== EVM Automate Method: <#{@method}> GetIP --> #{prov.options[:vm_target_name]}.#{dnsdomain} with IP Address #{nextIPADDR} FAILED")
          exit MIQ_ABORT
        else
          $evm.log("info", "===== EVM Automate Method: <#{@method}> GetIP --> unknown error")
        end

    end
  else
    $evm.log("info", "===== EVM Automate Method: <#{@method}> Vendor Type: #{vm_data['vendor']} skipping Infoblox Integration")
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