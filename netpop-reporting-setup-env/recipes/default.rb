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
  owner     reporting_user
  group     reporting_group
  mode      0775
  recursive true
end

include_recipe "monit"
