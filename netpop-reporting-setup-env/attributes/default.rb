default[:netpop_reporting][:deploy_path] = "/srv/netpop-reporting"
default[:netpop_reporting][:user]        = "reporting"
default[:netpop_reporting][:group]       = "admin" # for now, use the pre-existing group "admin" which also grants sudo access
default[:netpop_reporting][:env]         = "reporting"
