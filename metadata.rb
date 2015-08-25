name             'gocd_agent'
version          '1.1.11'

license          'MIT'
maintainer       'James M. Greene'
maintainer_email 'james.m.greene@gmail.com'
description      'Install and configure a ThoughtWorks Go CD (GoCD) Agent/Client'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url       'https://github.com/JamesMGreene/chef-gocd-agent'        if respond_to?(:source_url)
issues_url       'https://github.com/JamesMGreene/chef-gocd-agent/issues' if respond_to?(:issues_url)


# GoCD depends on the OpenJDK 7 (1.7.x) JRE
depends 'java', '~> 1.31'



####################################################################################################
#
# List of known platforms for Chef Supermarket:
#   https://github.com/chef/supermarket/blob/master/app/helpers/supported_platforms_helper.rb
#
# List of known platforms for Chef Client (look for "PROVIDERS" object):
#   https://github.com/chef/chef/blob/master/spec/unit/provider_resolver_spec.rb#L541-L827
#
####################################################################################################

# Linux: 'rhel' platform_family
supports 'amazon'
supports 'redhat'
supports 'centos'
supports 'scientific'
supports 'oracle'

# Linux: 'fedora' platform_family (basically 'rhel')
supports 'fedora'

# Linux: 'debian' platform_family
supports 'debian'
supports 'ubuntu'
supports 'linuxmint'

# Mac: 'mac_os_x'/'darwin' platform_family
supports 'mac_os_x'
supports 'mac_os_x_server'

# Windows: 'windows' platform_family
supports 'windows'
supports 'mingw32'
supports 'mswin'

# Solaris & Friends
supports 'solaris'
supports 'solaris2'
supports 'opensolaris'
supports 'omnios'
supports 'smartos'
