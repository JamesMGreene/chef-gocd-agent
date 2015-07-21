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


# Install any required dependencies, e.g. OpenJDK 7
include_recipe 'gocd_agent::_install_prereqs'


# Download the appropriate installation source
include_recipe 'gocd_agent::_download_materials'


installer_dir  = File.dirname(node['gocd_agent']['installation_source'])
installer_file = File.basename(node['gocd_agent']['installation_source'])

# Install it as a binary!
case node['platform_family']
when 'mac_os_x'
  # app
  execute 'Copy the ".app" file (directory) into the "/Applications" directory' do
    cwd     installer_dir
    command "mv '#{installer_file}' /Applications"
    only_if {
      File.dir?('/Applications') &&
      File.dir?(node['gocd_agent']['installation_source']) &&
      installer_file.end_with?('.app')
    }
  end

when 'windows'
  # exe
  execute 'Install the Go Agent silently on Windows' do
    cwd     installer_dir
    command "#{installer_file} /S"
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


# Register, enable, and start the new service
include_recipe 'gocd_agent::service'
