##
#
# Cookbook Name:: netpop-reporting-setup-env
# Recipe:: default
#
# Copyright 2011, Web System Studio, Inc
#
# All rights reserved - Do Not Redistribute
#
##
# what it does:
#   1) set directory permissions to allow for capistrano deployment
#   2) install server software needed by the app (just monit for now)
##

deploy_to       = "/srv/netpop-reporting"
reporting_user  = "reporting"
reporting_group = "apps"

bash "create group for apps" do
  code "addgroup #{reporting_group}"
  only_if "test 0 -eq `grep -c #{reporting_group} /etc/group`" # only_if does NOT exist
end

bash "create user account for reporting" do
  code "adduser --ingroup apps #{reporting_user}"
  only_if "test 0 -eq `grep -c #{reporting_user} /etc/passwd`" # only_if does NOT exist
end

directory deploy_to do
  action    :create
  recursive true
  owner     reporting_user
  group     reporting_group
  mode      "775" # When specifying the mode, the value can be a quoted string, eg "644". For a numeric value, it should be 5 digits, eg "00644" to ensure that Ruby can parse it correctly
end

##
# put the SSH key for github in place. depends on existance of the user's ~/.ssh folder
cookbook_file "/home/#{reporting_user}/.ssh/id_rsa" do
  source    "id_rsa"
  action    :create
  recursive true
  owner     reporting_user
  mode      "700" # must be highly restricted perms or SSH agent will not use it
  not_if    "test -f /home/#{reporting_user}/.ssh/id_rsa" # not_if file exists
end

gem_package 'rake'
gem_package 'rails' do
  action :install
  version "2.3.4"
end

include_recipe "monit"
