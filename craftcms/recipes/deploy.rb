Chef::Log.info("-- DEPLOY START")

def deploy_website(app)    
    Chef::Log.info("--- deploy web site app_id: " + app['app_id'])
    site_user = app['environment']['SITE_USER']    
    Chef::Log.info("--- create site user " + site_user)

    data_source = app['data_sources'][0]
    rds_instance = search("aws_opsworks_rds_db_instance").first

    Chef::Log.info("RDS info=#{rds_instance.inspect}")

    site_domain = app['domains'][0]

    Chef::Log.info('domain: ' + site_domain)

    home_path = '/home/' + site_user

    user 'create_user' do
        comment site_user
        username site_user
        group 'www-data'
        manage_home true
        home home_path
        shell '/bin/bash'
    end
    
    site_source_url = app['app_source']['url']
    Chef::Log.info("--- check out site code " + site_source_url)

    application home_path + '/www' do
        # check out code
        owner 'ubuntu'
        group 'www-data'
        git home_path + '/www' do
            repository site_source_url
            reference 'master'
            action :sync
            deploy_key app['app_source']['ssh_key']
        end   
    end

    execute "update group permission" do
        action :run
        command 'chgrp -R www-data ' + home_path +'/www/craftcms'
    end

    execute "update group write" do
        action :run
        command 'chmod -R g+w ' + home_path +'/www/craftcms'
    end

    Chef::Log.info("--- create virtual site template")

    use_ssl = app['enable_ssl']
    # contains certificate and 
    ssl_config = app['ssl_configuration']
    ssl_cert = ssl_config['certificate']
    ssl_key = ssl_config['private_key']

    if (use_ssl != nil) && use_ssl
      Chef::Log.info("--- deploying with SSL")
      Chef::Log.info("certificate " + ssl_cert)
      Chef::Log.info("private key " + ssl_key)

      # create the certificate and key files
      file home_path +'/www/craftcms/ssl/certificate.crt' do
        content ssl_cert
        mode '0400'
        owner 'ubuntu'
        group 'ubuntu'
      end

      file home_path +'/www/craftcms/ssl/certificate.key' do
        content ssl_key
        mode '0400'
        owner 'ubuntu'
        group 'ubuntu'
      end      
      
      template "/etc/apache2/sites-available/" + site_domain + '.conf' do
        source "virtual-host-ssl.conf.erb"
        mode '0755'
        variables(
          :site_domain => site_domain,
          :home_path => home_path
        )
      end
    else      
      Chef::Log.info("--- deploying without SSL")
      template "/etc/apache2/sites-available/" + site_domain + '.conf' do
        source "virtual-host.conf.erb"
        mode '0755'
        variables(
          :site_domain => site_domain,
          :home_path => home_path
        )
      end
    end

    Chef::Log.info("--- create log folder")
    directory home_path + '/www/logs' do
      owner site_user
      group 'www-data'
      mode '0775'
      recursive true
    end

    Chef::Log.info("--- create .htaccess")
    template home_path + "/www/craftcms/public/.htaccess" do
      owner site_user
      group 'www-data'
      source "htaccess.erb"
      mode '0755'
    end

    Chef::Log.info("--- remove htaccess")
    execute "remove htaccess file" do
      action :run
      command "rm -f " + home_path + "/www/craftcms/public/htaccess"
    end

    template home_path + "/www/craftcms/craft/config/db.php" do
      source "db.php.erb"
      mode 0660

      variables(
        :host =>     (rds_instance[:address]),
        :user =>     (rds_instance[:db_user]),
        :password => (rds_instance[:db_password]),
        :database_name =>  (data_source[:database_name])      
      )
    end    

    apache_module "rewrite" do
      enable true
    end

    apache_module "mpm_event" do 
      enable false
    end

    apache_module "mpm_prefork" do 
      enable true
    end

    apache_module "socache_shmcb" do 
      enable true
    end

    apache_module "ssl" do 
      enable true
    end

    service "apache2" do
      action :restart
    end

    # enable the site
    Chef::Log.info("--- enable site")
    apache_site site_domain do
      enable true
    end    
        
end

search("aws_opsworks_command").each do |command|
  Chef::Log.info("*** command: " + command.inspect)
end

op_command = search("aws_opsworks_command").first
if op_command['type'] == 'deploy'
    # list the hosts
    Chef::Log.info("HOSTS:")
    search("aws_opsworks_instance").each do |instance|
      Chef::Log.info(" -- instance:" + instance.inspect)
    end
    # list the apps
    Chef::Log.info("APPS:")
    search("aws_opsworks_app").each do |app|
      Chef::Log.info(" -- app:" + app.inspect)
    end
    # deploy the app to the instance
    search('aws_opsworks_app').each do |app|
      op_command['args']['app_ids'].each do |app_id|
          if app_id == app['app_id']
              deploy_website(app)
          end
      end
    end
end     

Chef::Log.info("-- DEPLOY COMPLETE")
