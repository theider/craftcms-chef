Chef::Log.info("-- SETUP START")

include_recipe "apache2"

apache_site "default" do
    enable true
end

package "php5" do
    action :install
end

package "php5-mysql" do
    action :install
end

package "mod_php5" do
    action :install    
end

Chef::Log.info("-- SETUP COMPLETE")