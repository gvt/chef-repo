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
#   2) install server software needed by the app (monit, DJ, etc)
##

deploy_to = "/srv/netpop-reporting"

bash "create group for apps" do
  new_group = "apps"
  code "addgroup #{new_group}"
  not_if "test -z `grep #{new_group} /etc/group`" # only if not already exists
end

bash "create user account for reporting" do
  new_user = "reporting"
  code "adduser --ingroup apps #{new_user}"
  not_if "test -z `grep #{new_user} /etc/passwd`" # only if not already exists
end

directory deploy_to do
  owner     "reporting"
  group     "apps"
  mode      0775
end

include_recipe "monit"
