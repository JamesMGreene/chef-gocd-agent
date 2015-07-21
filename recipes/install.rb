################################################################################
#
# Cookbook:: gocd_agent
# Recipe::   install
#
# Purpose:   Install and configure a ThoughtWorks Go CD (GoCD) Agent/Client
#
################################################################################


# Delegate to the configured installation mechanism
include_recipe "gocd_agent::install_from_#{node['gocd_agent']['install_method']}"
