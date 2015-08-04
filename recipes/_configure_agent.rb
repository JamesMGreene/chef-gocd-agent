######################
#                    #
#   PRIVATE RECIPE   #
#                    #
######################


# Defaults (most common)
default_config_template = 'config_linux.erb'
default_config_file = '/etc/default/go-agent'
config_dir = '/var/lib/go-agent/config'
dirs_to_create = %w(
  /etc/default
  /usr/share/go-agent
  /var/lib/go-agent
  /var/log/go-agent
  /var/run/go-agent
)

case node['gocd_agent']['install_method']
when 'package'
  if node['platform_family'] == 'windows' || node['platform_family'] == 'mac_os_x'
    raise "Unexpected value for `node['platform_family']` during 'package' installation: #{node['platform_family']}"
  end

when 'binary'

  default_config_template = "config_#{node['platform_family']}.erb"
  dirs_to_create = []

  case node['platform_family']
  when 'windows'
    if File.dir?('C:/Program Files (x86)')
      prog_files_dir = 'C:/Program Files (x86)'
    elsif File.dir?('C:/Program Files')
      prog_files_dir = 'C:/Program Files'
    else
      raise "No 'Program Files' directory on Windows!?"
    end

    default_config_file = "#{prog_files_dir}/Go Agent/config/wrapper-properties.conf"
    config_dir = "#{prog_files_dir}/Go Agent/config"

  when 'mac_os_x'
    default_config_file = "#{ENV['HOME']}/Library/Preferences/com.thoughtworks.studios.cruise.agent.properties"
    config_dir = '/Applications/Go Agent.app/Contents/Resources/config'

  else
    raise "Unexpected value for `node['platform_family']` during 'binary' installation: #{node['platform_family']}"
  end

when 'source'
  case node['platform_family']
  when 'mac_os_x'
    raise "Cannot handle a 'source' installation on `node['platform_family']`: #{node['platform_family']}"

  when 'windows'
    default_config_template = "config_#{node['platform_family']}.erb"
    dirs_to_create = []

    if File.dir?('C:/Program Files (x86)')
      prog_files_dir = 'C:/Program Files (x86)'
    elsif File.dir?('C:/Program Files')
      prog_files_dir = 'C:/Program Files'
    else
      raise "No 'Program Files' directory on Windows!?"
    end

    default_config_file = "#{prog_files_dir}/Go Agent/config/wrapper-properties.conf"
    config_dir = "#{prog_files_dir}/Go Agent/config"


  else  # Linux, UNIX, Solaris, etc.
    # Go with default values...

  end

else
  raise "Unexpected value for `node['gocd_agent']['install_method']`: #{node['gocd_agent']['install_method']}"
end


# Add one more important directory to the list!
dirs_to_create.push(config_dir)

# Set the path for the "autoregister.properties" file
auto_reg_config_file = "#{config_dir}/autoregister.properties"


# Create any expected directories
dirs_to_create.each do |dir|
  directory dir do
    owner node['gocd_agent']['user']
    group node['gocd_agent']['group']
    mode  '0755'
    recursive true
  end
end


# Grab the real user PATH value
path_tempfile='/tmp/go.PATH.txt'

bash 'Save PATH to tempfile' do
  user node['gocd_agent']['user']
  code <<-EOH
    echo "${PATH}">#{path_tempfile}
    chmod 666 #{path_tempfile}
  EOH
end

ruby_block 'Retrieve PATH from tempfile' do
  block do
    node.normal['gocd_agent']['path'] = IO.read(path_tempfile).strip
    File.delete(path_tempfile)
  end
  only_if {
    File.file?(path_tempfile)
  }
end


# Generate the config file before starting the service. On some platforms,
# this avoids the first-time UI prompt asking for the Go Server hostname/IP.
template default_config_file do
  cookbook 'gocd_agent'
  source   default_config_template
  owner    node['gocd_agent']['user']
  group    node['gocd_agent']['group']
  mode     '0644'
  notifies :restart, 'service[go-agent]', :delayed
end

# Create the "log4j.properties" file if the key is set
template "#{config_dir}/log4j.properties" do
  cookbook 'gocd_agent'
  source   'log4j.properties.erb'
  owner    node['gocd_agent']['user']
  group    node['gocd_agent']['group']
  mode     '0644'
  notifies :restart, 'service[go-agent]', :delayed
end

# Create the "autoregister.properties" file if the key is set
template auto_reg_config_file do
  cookbook 'gocd_agent'
  source   'autoregister.properties.erb'
  owner    node['gocd_agent']['user']
  group    node['gocd_agent']['group']
  mode     '0600'
  notifies :restart, 'service[go-agent]', :delayed
  only_if {
    !node['gocd_agent']['auto_register']['key'].nil? &&
    !node['gocd_agent']['auto_register']['key'].empty?
  }
end

# Delete the "autoregister.properties" file if the key is NOT set
file auto_reg_config_file do
  action   :delete
  notifies :restart, 'service[go-agent]', :delayed
  not_if {
    !node['gocd_agent']['auto_register']['key'].nil? &&
    !node['gocd_agent']['auto_register']['key'].empty?
  }
end
