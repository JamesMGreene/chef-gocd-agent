#!/bin/bash

BUNDLE_GEMFILE=test/Gemfile bundle install
if [[ $? -ne 0 ]]; then
  echo ''>&2
  echo 'ERROR! `bundle install` failed'>&2
  exit 1
fi

BUNDLE_GEMFILE=test/Gemfile bundle exec rake knife
if [[ $? -ne 0 ]]; then
  echo ''>&2
  echo 'ERROR! RakeTask `knife` test failed'>&2
  exit 1
fi

BUNDLE_GEMFILE=test/Gemfile bundle exec rake foodcritic
if [[ $? -ne 0 ]]; then
  echo ''>&2
  echo 'ERROR! RakeTask `foodcritic` test failed'>&2
  exit 1
fi

echo ''
echo 'All tests passed!'
exit 0
