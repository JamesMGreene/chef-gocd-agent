if node['platform_family'] == 'windows'
  if File.dir?('C:/Program Files (x86)')
    prog_files_dir = 'C:/Program Files (x86)'
  elsif File.dir?('C:/Program Files')
    prog_files_dir = 'C:/Program Files'
  else
    raise "No 'Program Files' directory on Windows!?"
  end

  agent_root_dir = "#{prog_files_dir}/Go Agent"
  agent_root_dir_shell = agent_root_dir.gsub('/', File.ALT_SEPARATOR)
end


service 'go-agent' do
  service_name node['gocd_agent']['service']
  action       [ :nothing ]
  supports     :status => true, :restart => true, :reload => false

  not_if {
    node['gocd_agent']['install_method'] == 'source' &&
    node['platform_family'] == 'windows'
  }
end

service 'go-agent' do
  service_name  node['gocd_agent']['service']
  action        [ :nothing ]
  supports      :status => false, :restart => false, :reload => false
  start_command "pushd '#{agent_root_dir_shell}'; start-agent.bat; popd"
  stop_command  "pushd '#{agent_root_dir_shell}'; stop-agent.bat; popd"

  only_if {
    node['gocd_agent']['install_method'] == 'source' &&
    node['platform_family'] == 'windows'
  }
end
