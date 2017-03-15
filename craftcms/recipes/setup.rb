Chef::Log.info("-- SETUP START")

include_recipe "apache2"

apache_site "default" do
    enable true
end

package "php" do
    action :install
    version "5.6"
end

Chef::Log.info("-- SETUP COMPLETE")