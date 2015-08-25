###
# Do NOT use this file to override this cookbook's default attributes.
# Instead, please use the "customize.rb" attributes file, which will keep
# your adjustments separate from the codebase and make it easier to upgrade.
#
# However, you should not edit "customize.rb" directly. Instead, create a
# "{thisCookbookName}/attributes/customize.rb" file in your own cookbook
# repository and put the overrides in YOUR "customize.rb" file.
#
# Do NOT create an "{thisCookbookName}/attributes/default.rb" in your
# cookbooks. Doing so would completely override this file and might cause
# upgrade issues.
###

# The Basics
default['gocd_agent']['name']    = 'go-agent'
default['gocd_agent']['version'] = '15.2.0'
default['gocd_agent']['release'] = '2248'

# Configure communication with the GoCD Server
default['gocd_agent']['gocd_server']['host'] = '127.0.0.1'
default['gocd_agent']['gocd_server']['port'] = 8153

# Configure local agent settings; ideally, you should leave these unset/default
default['gocd_agent']['work_dir'] = nil
default['gocd_agent']['home'] = '/var/go'
default['gocd_agent']['path'] = ENV['PATH']
if !(ENV['JAVA_HOME'].nil? || ENV['JAVA_HOME'].empty?)
  default['gocd_agent']['java_home'] = ENV['JAVA_HOME']
else
  case node['platform_family']
  when 'windows'
    cmd = Mixlib::ShellOut.new('echo "${JAVA_HOME}"')
  else
    cmd = Mixlib::ShellOut.new('echo "${JAVA_HOME}"', :user => 'root')
  end
  cmd.run_command
  if !(cmd.error? || cmd.stdout.nil? || cmd.stdout.strip.empty?)
    default['gocd_agent']['java_home'] = cmd.stdout.strip
  end
end



# Auto-register new GoCD Agents with the GoCD Server?
default['gocd_agent']['auto_register']['key']          = nil
default['gocd_agent']['auto_register']['resources']    = []
default['gocd_agent']['auto_register']['environments'] = []
# Requires GoCD 15.2.0 or higher
default['gocd_agent']['auto_register']['hostname']     = node['hostname']

# User/Group
default['gocd_agent']['user']  = 'go'
default['gocd_agent']['group'] = 'go'

# Install prereqs?
default['gocd_agent']['install_prereqs'] = true


# Configure the service name
case node['platform_family']
when 'solaris', 'solaris2', 'opensolaris', 'omnios', 'smartos'
  default['gocd_agent']['service'] = 'go/agent'
when 'windows'
  default['gocd_agent']['service'] = 'Go Agent'
else
  default['gocd_agent']['service'] = 'go-agent'
end



case node['platform_family']
when 'rhel', 'fedora'
  # yum (rpm)
  default['gocd_agent']['install_method'] = 'package'

when 'debian'
  # apt/apt-get (deb)
  default['gocd_agent']['install_method'] = 'package'

when 'solaris', 'solaris2', 'opensolaris', 'omnios', 'smartos'
  # pkgadd/pkgin (pkgsrc) - gzipped
  default['gocd_agent']['install_method'] = 'package'

when 'mac_os_x'
  # app - zipped
  default['gocd_agent']['install_method'] = 'binary'

when 'windows'
  # exe - Setup Installer
  default['gocd_agent']['install_method'] = 'binary'

else
  # Other platforms: primarily other Linux/UNIX/BSD variants
  # source - zipped
  default['gocd_agent']['install_method'] = 'source'

end


case node['gocd_agent']['install_method']
when 'package'

  case node['platform_family']
  when 'rhel', 'fedora'
    # yum (rpm)
    default['gocd_agent']['download_dir'] = '/gocd/gocd-rpm'
    default['gocd_agent']['download_file_extension'] = '.noarch.rpm'
    default['gocd_agent']['decompress'] = nil

  when 'debian'
    # apt/apt-get (deb)
    default['gocd_agent']['download_dir'] = '/gocd/gocd-deb'
    default['gocd_agent']['download_file_extension'] = '.deb'
    default['gocd_agent']['decompress'] = nil

  when 'solaris', 'solaris2', 'opensolaris', 'omnios', 'smartos'
    # pkgadd/pkgin (pkgsrc) - gzipped
    default['gocd_agent']['download_dir'] = '/gocd/gocd'
    default['gocd_agent']['download_file_extension'] = '-solaris.gz'
    default['gocd_agent']['decompress'] = 'gzip'

  end

when 'binary'

  case node['platform_family']
  when 'mac_os_x'
    # app - zipped
    default['gocd_agent']['download_dir'] = '/gocd/gocd'
    default['gocd_agent']['download_file_extension'] = '-osx.zip'
    default['gocd_agent']['decompress'] = 'zip'

  when 'windows'
    # exe - Setup Installer
    default['gocd_agent']['download_dir'] = '/gocd/gocd'
    default['gocd_agent']['download_file_extension'] = '-setup.exe'
    default['gocd_agent']['decompress'] = nil

  end

when 'source'

  # source - zipped
  default['gocd_agent']['download_dir'] = '/gocd/gocd'
  default['gocd_agent']['download_file_extension'] = '.zip'
  default['gocd_agent']['decompress'] = 'zip'

else
  raise "Unexpected value for `node['gocd_agent']['install_method']`: #{node['gocd_agent']['install_method']}"
end


# Configure the download
default['gocd_agent']['download_host'] = 'http://dl.bintray.com'
default['gocd_agent']['download_file_basename'] = "#{node['gocd_agent']['name']}-#{node['gocd_agent']['version']}-#{node['gocd_agent']['release']}"
default['gocd_agent']['download_file'] = "#{node['gocd_agent']['download_file_basename']}#{node['gocd_agent']['download_file_extension']}"
default['gocd_agent']['download_url']  = "#{node['gocd_agent']['download_host']}#{node['gocd_agent']['download_dir']}/#{node['gocd_agent']['download_file']}"


# Import custom attribute overrides
include_attribute 'gocd_agent::customize'
