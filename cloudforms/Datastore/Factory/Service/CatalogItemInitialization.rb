###################################
#
# CFME Automate Method: POC_CatalogItemInitialization
#
# by Keivn Morey
#
# Notes: This method Performs the following functions:
# 1. Append a datetime stamp to the end of the service name
# 2. Get all Service Dialog Options in service_template_provision_task.dialog_options
#    (I.e. Dialog options that came from a Catalog Item/Service Dialog)
# 3. Service dialog option keys that match the regular expression /^dialog_tag_\d*_(.*)/i (I.e. <dialog>_<tag>_<group_idx>_variable)
#    - Tags with <group_idx> of 0-9 will be used to tag the service and all subordinate miq_provision tasks (dialog_tag_0_environment).
# 4. Service dialog option key that equals dialog_options['dialog_service_size'] will determine the mapping to small, medium, large or xlarge.
# 5. Service dialog option keys that match the regular expression /^dialog_option_\d*_(.*)/i (I.e. <dialog>_<option>_<group_idx>_variable)
#    - Options keys with <group_idx> of 0-9 will be used to apply this option to all subordinate miq_provision task (dialog_option_1_vm_memory).
#    I.e. dialog_option_0_vm_memory => 2048, dialog_option_1_vm_target_name => 'vm123'
# 6. Update subordinate miq_provision tasks with :vm_target_hostname from nil to the value of :vm_target_name because by the time this method
#    runs vmname has already been run and if you are deploying rhel on vmware with a customization specification the name must be set or provisioning can fail.
#
# Inputs: $evm.root['service_template_provision_task'].dialog_options
#
###################################
begin
  # Method for logging
  def log(level, message)
    @method = 'POC_CatalogItemInitialization'
    $evm.log(level, "#{@method}: #{message}")
  end

  # dump_root
  def dump_root()
    log(:info, "Root:<$evm.root> Begin $evm.root.attributes")
    $evm.root.attributes.sort.each { |k, v| log(:info, "Root:<$evm.root> Attribute - #{k}: #{v}")}
    log(:info, "Root:<$evm.root> End $evm.root.attributes")
    log(:info, "")
  end

  # get_tags_hash - Look for service dialog variables in the dialog options hash that start with "dialog_tag_[0-9]"
  def get_tags_hash(dialog_options)
    # Setup regular expression for service dialog tags
    tags_regex = /^dialog_tag_\d*_(.*)/
    tags_hash = {}

    # Loop through all of the tags and build an options_hash from them
    dialog_options.each do |k,v|
      if tags_regex =~ k
        #log(:info, "Processing Tag Key:<#{k.inspect}> Value:<#{v.inspect}>")
        # Convert key to symbol
        tag_category = $1.to_sym
        tag_value = v.downcase

        unless tag_value.blank?
          log(:info, "Adding category:<#{tag_category.inspect}> tag:<#{tag_value.inspect}> to tags_hash")
          tags_hash[tag_category] = tag_value
        end
      end
    end

    # Dump tags_hash to the log
    log(:info, "Inspecting tags_hash:<#{tags_hash.inspect}>")

    # Dynamically create categories and tags based on tags_hash
    tags_hash.each do |category, tag|
      process_tags(category, true, tag)
    end

    return tags_hash
  end

  # get_options_hash - Look for service dialog variables in the dialog options hash that start with "dialog_option_[0-9]"
  def get_options_hash(dialog_options)
    # Setup regular expression for service dialog tags
    options_regex = /^dialog_option_\d*_(.*)/
    options_hash = {}

    # Loop through all of the options and build an options_hash from them
    dialog_options.each do |k,v|
      if options_regex =~ k
        option_key = $1.to_sym
        option_value = v

        unless option_value.blank?
          log(:info, "Adding option_key:<#{option_key.inspect}> option_value:<#{option_value.inspect}> to options_hash")
          options_hash[option_key] = option_value
        end
      end
    end
    log(:info, "Inspecting options_hash:<#{options_hash.inspect}>")
    return options_hash
  end

  # get_service_type
  def get_service_type(service, dialog_options)
    log(:info, "Detected service:<#{service.name}> service_size:<#{dialog_options['dialog_service_size']}>")

    case dialog_options['dialog_service_size'].downcase
      when "medium"
        # 2 X 2
        dialog_options['dialog_option_1_vm_memory'] = 2048
        dialog_options['dialog_option_1_cores_per_socket'] = 2
      when "large"
        # 4 X 4
        dialog_options['dialog_option_1_vm_memory'] = 4096
        dialog_options['dialog_option_1_cores_per_socket'] = 4
      when "xlarge"
        # 8 X 8
        dialog_options['dialog_option_1_vm_memory'] = 8192
        dialog_options['dialog_option_1_cores_per_socket'] = 8
      else
        # 1 X 1
        dialog_options['dialog_option_1_vm_memory'] = 1024
        dialog_options['dialog_option_1_cores_per_socket'] = 1
    end
    log(:info, "Updated service:<#{service.name}> service_size:<#{dialog_options['dialog_service_size']}> cores_per_socket:<#{dialog_options['dialog_option_1_cores_per_socket']}> vm_memory:<#{dialog_options['dialog_option_1_vm_memory']}>")
  end

  # tag_service - tag the parent service with tags
  def tag_service(service, tags_hash)
    unless tags_hash.nil?
      tags_hash.each do |k,v|
        log(:info, "Adding Tag:<#{k.inspect}/#{v.inspect}> to Service:<#{service.name}>")
        service.tag_assign("#{k}/#{v}")
      end
    end
  end

  # name_service - name the service to avoid duplicate names
  def name_service(service, new_service_name=nil)
    unless new_service_name.blank?
      log(:info, "Changing Service name:<#{service.name}> to <#{new_service_name}>")
    else
      new_service_name = "#{service.name}-#{Time.now.strftime('%Y%m%d-%H%M%S')}"
      log(:info, "Changing Service name:<#{service.name}> to <#{new_service_name}>")
    end
    service.name = new_service_name
  end

  # set_service_retirement - default the service retirement to 3 days warning 1 day
  def set_service_retirement(service, dialog_options)
    service_retirement = dialog_options.fetch('dialog_service_retirement', 3)
    service_retirement_warning = dialog_options.fetch('dialog_service_retirement_warning', 1)
    new_service_retirement = (DateTime.now + service_retirement.to_i).strftime("%Y-%m-%d")
    log(:info, "Changing Service:<#{service.name}> retires_on:<#{new_service_retirement}> retirement_warn:<#{service_retirement_warning}>")
    service.retires_on = new_service_retirement.to_date
    service.retirement_warn = service_retirement_warning.to_i
  end

  # process_tags - Dynamically create categories and tags
  def process_tags( category, single_value, tag )
    # Convert to lower case and replace all non-word characters with underscores
    category_name = category.to_s.downcase.gsub(/\W/, '_')
    tag_name = tag.to_s.downcase.gsub(/\W/, '_')
    log(:info, "Converted category name:<#{category_name}> Converted tag name: <#{tag_name}>")
    # if the category exists else create it
    unless $evm.execute('category_exists?', category_name)
      log(:info, "Category <#{category_name}> doesn't exist, creating category")
      $evm.execute('category_create', :name => category_name, :single_value => single_value, :description => "#{category}")
    end
    # if the tag exists else create it
    unless $evm.execute('tag_exists?', category_name, tag_name)
      log(:info, "Adding new tag <#{tag_name}> in Category <#{category_name}>")
      $evm.execute('tag_create', category_name, :name => tag_name, :description => "#{tag}")
    end
  end

  log(:info, "CFME Automate Method Started")

  # dump all root attributes to the log
  dump_root()

  # Get the task object from root
  service_template_provision_task = $evm.root['service_template_provision_task']

  # Get destination service object
  service = service_template_provision_task.destination
  log(:info, "Detected Service:<#{service.name}> Id:<#{service.id}> Tasks:<#{service_template_provision_task.miq_request_tasks.count}>")

  # Get dialog options from task
  dialog_options = service_template_provision_task.dialog_options
  log(:info, "Inspecting Dialog Options:<#{dialog_options.inspect}>")

  # Get tags_hash
  tags_hash = get_tags_hash(dialog_options)

  # Tag Service
  tag_service(service, tags_hash)

  # Name Service
#  dialog_service_name = dialog_options.fetch('dialog_service_name', nil)
  dialog_service_name = dialog_options.fetch('dialog_option_1_vm_target_name', nil)
  name_service(service, dialog_service_name)

  # Set Service Retirement
  set_service_retirement(service, dialog_options)

  # get_service_type
  dialog_service_size = dialog_options.fetch('dialog_service_size', nil)
  get_service_type(service, dialog_options) unless dialog_service_size.blank?

  # Get options_hash
  options_hash = get_options_hash(dialog_options)

  # Process Child Tasks
  service_template_provision_task.miq_request_tasks.each do |t|
    # Child Service
    child_service = t.destination
    log(:info, "Child Service:<#{child_service.name}>")

    # Process grandchildren service options
    unless t.miq_request_tasks.nil?
      grandchild_tasks = t.miq_request_tasks
      #log(:info,"#{@method} - Inspecting Grandchild Tasks:<#{grandchild_tasks.inspect}>")

      # Loop through each child provisioning object and applya tags and options
      grandchild_tasks.each do |gc|
        log(:info, "Detected Grandchild Task ID:<#{gc.id}> Description:<#{gc.description}> source type:<#{gc.source_type}>")

        # If child task is provisioning then apply tags and options
        if gc.source_type == "template"
          unless tags_hash.nil?
            tags_hash.each do |k,v|
              log(:info, "Adding Tag:<#{k.inspect}/#{v.inspect}> to Provisioning ID:<#{gc.id}>")
              gc.add_tag(k, v)
            end
          end
          unless options_hash.nil?
            options_hash.each do |k,v|
              log(:info, "Adding Option:<{#{k.inspect} => #{v.inspect}}> to Provisioning ID:<#{gc.id}>")
              gc.set_option(k,v)
            end
            # Dump all provisioning options to the log
            #gc.options.each { |k,v| log(:info,"Provisioning Option Key:<#{k.inspect}> Value:<#{v.inspect}>") }

            # Update :vm_target_hostname from :vm_target_name since vmname method has already been run
            gc.set_option(:vm_target_hostname, gc.get_option(:vm_target_name))
            log(:info, "Adding Option prov.set_option(:vm_target_hostname, #{gc.get_option(:vm_target_hostname)}) to Provisioning ID:<#{gc.id}>")
          end

        else
          log(:info, "Invalid Source Type:<#{gc.source_type}>. Skipping task ID:<#{gc.id}>")
        end # if gc.source_type
      end # grandchild_tasks.each do
    end # unless t.miq_request_tasks.nil?
  end # service_template_provision_task.miq_request_tasks.each do

  # Exit method
  log(:info, "CFME Automate Method Ended")
  exit MIQ_OK

    # Ruby rescue
rescue => err
  log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  exit MIQ_ABORT
end