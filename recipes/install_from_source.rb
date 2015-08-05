################################################################################
#
# Cookbook:: gocd_agent
# Recipe::   install_from_source
#
# Purpose:   Install and configure a ThoughtWorks Go CD (GoCD) Agent/Client
#
################################################################################


# Force the installation method to to "source"
node.force_override['gocd_agent']['install_method'] = 'source'  # ~FC019 (https://github.com/acrmp/foodcritic/pull/312)



# Register the service but do not perform any actions
include_recipe 'gocd_agent::service'

# Stop the service, if it was previously running
service 'go-agent' do
  action [ :stop ]
end


# Install any required dependencies, e.g. OpenJDK 7
include_recipe 'gocd_agent::_install_prereqs'


# Download the appropriate installation source
include_recipe 'gocd_agent::_download_materials'


# Update the Agent configuration before installing it, as this will ensure that
# all of the important directories get created in advance!
include_recipe 'gocd_agent::_configure_agent'


# Install it all... very manually....
files_to_copy = {}
case node['platform_family']
when 'windows'
  if File.dir?('C:/Program Files (x86)')
    prog_files_dir = 'C:/Program Files (x86)'
  elsif File.dir?('C:/Program Files')
    prog_files_dir = 'C:/Program Files'
  else
    raise "No 'Program Files' directory on Windows!?"
  end
  agent_root_dir = "#{prog_files_dir}/Go Agent"

  files_to_copy["#{agent_root_dir}/agent-bootstrapper.jar"] = 'agent-bootstrapper.jar'
  files_to_copy["#{agent_root_dir}/agent.cmd"] = 'agent.cmd'
  files_to_copy["#{agent_root_dir}/start-agent.bat"] = 'start-agent.bat'
  files_to_copy["#{agent_root_dir}/stop-agent.bat"] = 'stop-agent.bat'
else
  files_to_copy['/usr/share/go-agent/agent-bootstrapper.jar'] = 'agent-bootstrapper.jar'
  files_to_copy['/etc/init.d/go-agent'] = 'init.cruise-agent'
  files_to_copy['/usr/share/go-agent/agent.sh'] = 'agent.sh'
  files_to_copy['/usr/share/go-agent/stop-agent.sh'] = 'stop-agent.sh'
end


files_to_copy.each do |dest, src|
  remote_file dest do
    owner  node['gocd_agent']['user']
    group  node['gocd_agent']['group']
    source lazy { "file://#{node['gocd_agent']['installation_source']}/#{src}" }
    mode   '0751'
    only_if {
      File.dir?(node['gocd_agent']['installation_source']) &&
      File.file?("#{node['gocd_agent']['installation_source']}/#{src}") &&
      File.dir?(File.dirname(src))
    }
  end
end


# Enable and start the service
service 'go-agent' do
  action [ :enable, :start ]
end
