###################################
#
# EVM Automate Method: Infoblox_Delete_Record
#
# Notes: EVM Automate method to add Host entry to Infoblox
#
###################################
begin
  @method = 'Infoblox_Delete_Record'
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
  # Delete Alias                   #
  ##################################
  def deleteAlias(item)
    begin
      url = 'https://' + @connection + '/wapi/v1.0/' + item
      dooie = RestClient.delete url
      $evm.log("info", "===== EVM Automate Method: <#{@method}> Deleting Alias for host - #{@name} Alias: #{item}")
      return true
    rescue Exception => e
      puts e.inspect
      return false
    end
  end

  ##################################
  # DeleteAliases                   #
  ##################################
  def findAlias(host)
    begin
      url = 'https://' + @connection + '/wapi/v1.0/record:cname?' + "canonical=#{host}"
      dooie = RestClient.get url
      doc = Nokogiri::XML(dooie)
      root = doc.root
      hosts = root.xpath("value/_ref/text()")
      hosts.each do | a |
        a = a.to_s
        $evm.log("info", "===== EVM Automate Method: <#{@method}> Found Aliases for host - #{@name} Alias: #{a}")
        deleteAlias(a)
      end
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

  @name =  "#{vm['name']}.#{dnsdomain}"

  @connection = "#{username}:#{password}@#{servername}"

  $evm.log("info", "===== EVM Automate Method: <#{@method}> Fetching Host: #{@name}")
  sooie = fetchHost("#{@name}.#{dnsdomain}")
  if sooie ==  true
    $evm.log("info", "===== EVM Automate Method: <#{@method}> Host: #{@name} does NOT exist")
  else
    $evm.log("info", "===== EVM Automate Method: <#{@method}> Fetching Aliases for host - #{@name}")
    findAlias(@name)

    $evm.log("info", "===== EVM Automate Method: <#{@method}> Deleting Host - #{sooie}")
    deleteHost(sooie)
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