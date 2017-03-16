Chef::Log.info("-- SETUP START")

include_recipe "apache2"
include_recipe "apt"

apt_update

apache_site "default" do
    enable true
end

Chef::Log.info("-- SETUP COMPLETE")