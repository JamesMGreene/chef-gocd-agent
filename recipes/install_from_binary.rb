################################################################################
#
# Cookbook:: gocd_agent
# Recipe::   install_from_binary
#
# Purpose:   Install and configure a ThoughtWorks Go CD (GoCD) Agent/Client
#
################################################################################


if node.default['gocd_agent']['install_method'] != 'binary'
  raise 'This platform cannot be installed via the "binary" mechanism'
end


# Force the installation method to to "binary"
node.force_override['gocd_agent']['install_method'] = 'binary'  # ~FC019 (https://github.com/acrmp/foodcritic/pull/312)



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


# Install it as a binary!
case node['platform_family']
when 'mac_os_x'
  # app
  execute 'Copy the ".app" file (directory) into the "/Applications" directory' do
    cwd     lazy { File.dirname(node['gocd_agent']['installation_source']) }
    command lazy { "mv '#{File.basename(node['gocd_agent']['installation_source'])}' /Applications" }
    only_if {
      File.dir?('/Applications') &&
      File.dir?(node['gocd_agent']['installation_source']) &&
      installer_file.end_with?('.app')
    }
  end

when 'windows'
  # exe
  execute 'Install the Go Agent silently on Windows' do
    cwd     lazy { File.dirname(node['gocd_agent']['installation_source']) }
    command lazy { "#{File.basename(node['gocd_agent']['installation_source'])} /S" }
  end

end


# Update the Agent configuration
include_recipe 'gocd_agent::_configure_agent'


# For MacOS X, don't open the App until after configuring the Go Agent as it
# starts the "service" and I am unsure of if that "service" will respond to
# Chef's `service['go-agent']` delegated commands (like `:restart`).
#
# Defering this until after the `configure_agent` step will also likely suppress
# the annoying first-time UI prompt asking for the GoCD Server hostname/IP.
execute 'Install the Go Agent silently on MacOS X' do
  cwd     '/Applications'
  command "open #{installer_file}"
  only_if { node['platform_family'] == 'mac_os_x' }
end


# Enable and start the service
service 'go-agent' do
  action [ :enable, :start ]
end
