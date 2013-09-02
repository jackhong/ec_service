#!/bin/bash

OMF_HOME=$HOME/nicta/omf5
CWD=$(dirname $0)

[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
rvm use ruby-1.8.7

exec ruby -I $OMF_HOME/omf-expctl/ruby -I $OMF_HOME/omf-common/ruby $OMF_HOME/omf-expctl/ruby/omf-expctl.rb \
  -N -C $CWD/etc/omf-expctl.norbit.yaml --log $CWD/etc/omf-expctl_log.xml $*
