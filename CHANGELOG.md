# `gocd_agent` CHANGELOG

This file is used to list changes made in each version of the `gocd_agent` cookbook.


## `1.1.11`
- Dropped the `:user` attribute from the `Mixlib::ShellOut` command when running on Windows.

## `1.1.10`
- Relaxed version constraint for the `java` dependency cookbook.

## `1.1.9`
- Now setting the `USER` environment variable on Linux.

## `1.1.8`
- Adjusted the `service` resource usage to stop the service before installing so that it is effectively restarted if the service was indeed already installed.

## `1.1.7`
- Added support for setting the `HOME` environment variable on Linux via new attribute `node['gocd_agent']['home']`.

## `1.1.6`
- Added support for prepending to the `PATH` environment variable via new attribute `node['gocd_agent']['path']`.

## `1.1.5`
- Fixed some instances of using non-existent String method 'trim' instead of 'strip'.

## `1.1.4`
- Drop the newer `:login` attribute from use of `Mixlib::ShellOut`... too modern for OpsWorks's Chef 11.10's "mixlib-shellout-1.3"!

## `1.1.3`
- Added better internal testing for Travis CI with `knife cookbook test`

## `1.1.2`
- Switched from using backtick-escaped line scripts to `Mixlib::ShellOut`

## `1.1.1`
- Added default value searches for `node['gocd_agent']['java_home']`.

## `1.1.0`
- Added new attribute to allow prereqs to **NOT** be forcibly installed.

## `1.0.12`
- Modified template for 'autoregister.properties' file to remove excess whitespace.

## `1.0.11`
- Adding attribute nodes for setting `work_dir` and `java_home` on Linux.

## `1.0.10`
- Fixed another attribute reference issue during Chef Compile phase vs. Converge phase, this time in
  the `service` resource.

## `1.0.9`
- Removed unnecessary `version` attribute from `package` installer resource.

## `1.0.8`
- Fixed issue with `node['gocd_agent']['installation_source']` being empty for installers due to
  their attributes being evaluated during the Chef Compile phase instead of the Converge phase by
  using `lazy` attribute evaluation where needed.
- Removed debugging code.

## `1.0.7`
- Syntax error fix. Sorry!

## `1.0.6`
- MOAR DEBUGGING!

## `1.0.5`
- Added some debugging code into a private recipe for analysis.

## `1.0.4`
- Shuffled some attribute definitions around to get the correct values propagated.

## `1.0.3`
- Added a link to the `java` cookbook dependency

## `1.0.2`
- Initial release of the `gocd_agent` cookbook!

- - -
Check the [Markdown Syntax Guide](http://daringfireball.net/projects/markdown/syntax) for help with Markdown.

The [Github Flavored Markdown page](http://github.github.com/github-flavored-markdown/) describes the differences between markdown on github and standard markdown.
