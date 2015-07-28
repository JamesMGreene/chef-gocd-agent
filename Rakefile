#!/usr/bin/env rake

task :default => 'foodcritic'

desc "Runs foodcritic linter"
task :foodcritic do
  if Gem::Version.new("1.9.2") <= Gem::Version.new(RUBY_VERSION.dup)
    Rake::Task[:prepare_sandbox].execute

    sh "foodcritic --epic-fail any #{sandbox_path}"

    # If [and only if] Foodcritic passes, destroy the whole sandbox and its roots
    Rake::Task[:destroy_sandbox].execute
  else
    puts "WARN: foodcritic run is skipped as Ruby #{RUBY_VERSION} is < 1.9.2."
  end
end

desc "Runs knife cookbook test"
task :knife do
  Rake::Task[:prepare_sandbox].execute

  sh "bundle exec knife cookbook test cookbook -c test/.chef/knife.rb -o #{sandbox_path}/../"

  # If [and only if] Foodcritic passes, destroy the whole sandbox and its roots
  Rake::Task[:destroy_sandbox].execute
end

task :clean_sandbox do
  rm_rf sandbox_path
  mkdir_p sandbox_path
end

task :prepare_sandbox do
  Rake::Task[:clean_sandbox].execute

  files = %w{*.md *.rb attributes definitions libraries files providers recipes resources templates}
  cp_r Dir.glob("{#{files.join(',')}}"), sandbox_path
  puts "\n\n"
end

task :destroy_sandbox do
  rm_rf File.join(File.dirname(__FILE__), 'tmp')
end


private
def sandbox_path
  File.join(File.dirname(__FILE__), %w(tmp cookbooks cookbook))
end
