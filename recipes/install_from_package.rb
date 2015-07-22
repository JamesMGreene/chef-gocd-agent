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


# Install any required dependencies, e.g. OpenJDK 7
include_recipe 'gocd_agent::_install_prereqs'


# Download the appropriate installation source
include_recipe 'gocd_agent::_download_materials'


# Install it as a package
package node['gocd_agent']['name'] do
  version "#{node['gocd_agent']['version']}-#{node['gocd_agent']['release']}"
  source  lazy { node['gocd_agent']['installation_source'] }
end


# Update the Agent configuration
include_recipe 'gocd_agent::_configure_agent'


# Register, enable, and start the new service
include_recipe 'gocd_agent::service'
