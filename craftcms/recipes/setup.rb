Chef::Log.info("-- SETUP START")

include_recipe "apache2"

apache_site "default" do
  enable true
end

Chef::Log.info("-- SETUP COMPLETE")