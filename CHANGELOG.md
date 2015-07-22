# `gocd_agent` CHANGELOG

This file is used to list changes made in each version of the `gocd_agent` cookbook.


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
