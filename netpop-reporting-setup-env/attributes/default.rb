default[:'netpop-reporting-setup-env'][:deploy_path] = "/srv/netpop-reporting"
default[:'netpop-reporting-setup-env'][:user]        = "reporting"
default[:'netpop-reporting-setup-env'][:group]       = "admin" # for now, use the pre-existing group "admin" which also grants sudo access
default[:'netpop-reporting-setup-env'][:env]         = "reporting"
