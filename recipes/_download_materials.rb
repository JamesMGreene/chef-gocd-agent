######################
#                    #
#   PRIVATE RECIPE   #
#                    #
######################


# Local variables
local_download_dir = Chef::Config[:file_cache_path]
local_archive_name = File.basename(node['gocd_agent']['download_file'], File.extname(node['gocd_agent']['download_file']))
local_extract_subdir = local_archive_name
local_extract_dir = "#{local_download_dir}/#{local_extract_subdir}"
local_download_archive = "#{local_extract_dir}/#{node['gocd_agent']['download_file']}"
local_extracted_file = "#{local_extract_dir}/#{local_archive_name}"



# Create a directory to extract the downloaded archive to
directory local_extract_dir


# Download the required package/binary/source file
remote_file local_download_archive do
  source node['gocd_agent']['download_url']
  mode   '0644'
  action :create_if_missing
end


# Decompress the downloaded file if need be
ruby_block 'Decompress the archive' do
  block do
    cmd = (node['gocd_agent']['decompress'] == 'gzip' ? 'gzip -d' : node['gocd_agent']['decompress'] == 'zip' ? 'unzip' : nil)

    if cmd.nil?
      raise "Unexpected value for `node['gocd_agent']['decompress']`: #{node['gocd_agent']['decompress']}"
    else
      if cmd == 'unzip'
        # Ensure that unzip utilities are installed
        package 'unzip'
      end

      execute "Decompress the package archive with '#{node['gocd_agent']['decompress'].gsub(/zip$/, 'unzip')}'" do
        cwd     File.dirname(local_download_archive)
        command "#{cmd} #{File.basename(local_download_archive)}"
      end
    end
  end

  only_if { !node['gocd_agent']['decompress'].nil? && !node['gocd_agent']['decompress'].empty? }
end


ruby_block 'Set the installation_source' do
  block do
    # Set the final installation source location
    if !node['gocd_agent']['decompress'].nil? && !node['gocd_agent']['decompress'].empty?
      if local_download_archive.end_with?('-osx.zip')
        node.normal['gocd_agent']['installation_source'] = "#{local_extract_dir}/Go Agent.app"
      elsif local_download_archive.end_with?("-#{node['gocd_agent']['release']}.zip")
        node.normal['gocd_agent']['installation_source'] = "#{local_extract_dir}/#{local_archive_name.split('-')[0...-1].join('-')}"
      else
        node.normal['gocd_agent']['installation_source'] = local_extracted_file
      end
    else
      node.normal['gocd_agent']['installation_source'] = local_download_archive
    end
  end
end
