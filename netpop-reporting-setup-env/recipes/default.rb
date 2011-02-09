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
# node.netpop_reporting.[...] set in ../attributes/default.rb
##

reporting_user  = node.netpop_reporting.user
reporting_group = node.netpop_reporting.group
user_home_dir   = "/home/#{reporting_user}"
user_ssh_dir    = "#{user_home_dir}/.ssh"
user_heroku     = "#{user_home_dir}/.heroku"

##
# create user account for reporting
bash "create user account for reporting" do
  code "adduser --ingroup #{reporting_group} #{reporting_user}"
  only_if "test 0 -eq `grep -c #{reporting_user} /etc/passwd`" # only_if does NOT exist
end

##
# create and set perms for containing dir of deploy location on file system
directory node.netpop_reporting.deploy_path do
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
  not_if    "test -f /home/#{node.netpop_reporting.user}/.ssh/id_rsa" # not_if file exists
end

##
# copy an authorized_keys file for this user, taken from ubuntu user's, because ubuntu user has the EC2 group key already
cookbook_file "#{user_ssh_dir}/authorized_keys" do
  source    "authorized_keys"
  action    :create
  owner     reporting_user
  mode      "600" # must be highly restricted perms or SSH agent will not use it
end

##
# add to gem sources so that gems can be downloaded without not found errors
bash "update gem sources" do
  code "gem sources -a http://gemcutter.org"
  code "gem sources -a http://gems.github.com"
end

##
# these gems are needed to get rake to run for the app
gem_package 'rake'
gem_package 'rails' do
  action :install
  version "2.3.4"
end
gem_package 'pg'
gem_package 'semanticart-is_paranoid' # for some reason the rake gems:install task tries to install "is_paranoid" rather than "semanticart-is_paranoid" which fails. this is different behavior than on Mac.

##
# creates reporting user's heroku dir at ~/.heroku
directory user_heroku do
  action    :create
  recursive true
  owner     reporting_user
  mode      "755" # readable and cd-able by others
end

##
# put file ~/.heroku/credentials for heroku gem to access to avoid prompt
cookbook_file "#{user_heroku}/credentials" do
  source    "heroku-credentials"
  action    :create
  owner     reporting_user
  mode      "644" # readable by others
end

##
# create database account for reporting_user, for delayed_job tasks which run as reporting user
postgresql_user reporting_user do
  action     :create
  password   "c0rtland"
  privileges :superuser => false, :createdb => true, :inherit => true, :login => true
end

##
# put file /etc/init.d/#{init_filename} for initialization along with the system-level stuff
template "/etc/init.d/netpop-reporting" do
  source    "netpop-reporting"
  action    :create
  owner     "root" # same as other scripts in this location
  mode      "755"  # same as other scripts in this location
end

##
# put file /home/<reporting_user>/script with sticky bit set, to be called by the init.d script
template "#{user_home_dir}" do
  source    "netpop-reporting.sh"
  action    :create
  owner     reporting_user
  mode      "6755" # sticky bit, so that anyone who runs it runs it as reporting_user
end

##
# configure netpop reporting to start upon instance start (stop expected to be harmless or no-op)
bash "configure netpop reporting to start upon instance start" do
  code "sudo update-rc.d netpop-reporting defaults 98 02"
end

##
# make convenience link for easy cd'ing
bash "make a symlink to deploy location" do
  code "ln -s #{node.netpop_reporting.deploy_path}/current app"
end
