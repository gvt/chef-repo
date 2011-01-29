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
reporting_group = "admin" # for now, use the pre-existing group "admin" which also grants sudo access
user_ssh_dir    = "/home/#{reporting_user}/.ssh"

##
# create user account for reporting
bash "create user account for reporting" do
  code "adduser --ingroup #{reporting_group} #{reporting_user}"
  only_if "test 0 -eq `grep -c #{reporting_user} /etc/passwd`" # only_if does NOT exist
end

##
# create deploy_to location on file system
directory deploy_to do
  action    :create
  recursive true
  owner     reporting_user
  mode      "775" # When specifying the mode, the value can be a quoted string, eg "644". For a numeric value, it should be 5 digits, eg "00644" to ensure that Ruby can parse it correctly
end

##
# creates user's SSH dir at ~/.ssh
directory user_ssh_dir do
  action    :create
  recursive true
  owner     reporting_user
end

##
# put the SSH key for github in place. depends on existance of user_ssh_dir
cookbook_file "#{user_ssh_dir}/id_rsa" do
  source    "id_rsa"
  action    :create
  owner     reporting_user
  mode      "600" # must be highly restricted perms or SSH agent will not use it
  not_if    "test -f /home/#{reporting_user}/.ssh/id_rsa" # not_if file exists
end

##
# copy an authorized_keys file for this user, taken from ubuntu user's, because ubuntu user has the EC2 group key already
cookbook_file "#{user_ssh_dir}/authorized_keys" do
  source    "authorized_keys"
  action    :create
  owner     reporting_user
  mode      "600" # must be highly restricted perms or SSH agent will not use it
end

gem_package 'rake'
gem_package 'rails' do
  action :install
  version "2.3.4"
end

include_recipe "monit" # needed?
