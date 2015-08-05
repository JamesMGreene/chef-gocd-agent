################################################################################
#
# Cookbook:: gocd_agent
# Recipe::   install_from_package
#
# Purpose:   Install and configure a ThoughtWorks Go CD (GoCD) Agent/Client
#
################################################################################


if node.default['gocd_agent']['install_method'] != 'package'
  raise 'This platform cannot be installed via the "package" mechanism'
end


# Force the installation method to to "package"
node.force_override['gocd_agent']['install_method'] = 'package'  # ~FC019 (https://github.com/acrmp/foodcritic/pull/312)



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


# Install it as a package
package node['gocd_agent']['name'] do
  source lazy { node['gocd_agent']['installation_source'] }
end


# Update the Agent configuration
include_recipe 'gocd_agent::_configure_agent'


# Enable and start the service
service 'go-agent' do
  action [ :enable, :start ]
end
