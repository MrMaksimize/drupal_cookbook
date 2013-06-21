action :create do

  group = new_resource.group.nil? ? node['apache']['group'] : new_resource.group
  uri       = new_resource.uri
  cnf_path  = new_resource.cnf_path ? new_resource.cnf_path : "#{new_resource.root}/cnf"
  doc_root  = new_resource.doc_root ? new_resource.doc_root : "#{new_resource.root}/build"
  site_path = "#{doc_root}/sites/#{new_resource.subdir}"
  kw_command_path = "#{node['drupal']['drush']['root']}/#{node['drupal']['drush']['version']}/commands/kraftwagen"

  #directory site_path do
  #  recursive true
  #  owner     new_resource.owner unless new_resource.owner.nil?
  #  group     group
  #  mode      0775
  #end

  git "#{kw_command_path}" do
    repository "git://github.com/kraftwagen/kraftwagen.git"
    reference "master"
    action :sync
  end

  execute "drush_cc" do
    command "drush cc drush"
    action :run
  end

  execute "kraftwagen_setup" do
    cwd "#{new_resource.root}"
    command "drush kw-s"
    action :run
  end

  template "#{cnf_path}/settings.php" do
    owner     new_resource.owner
    group     new_resource.group
    mode      0660
    if new_resource.settings_source.nil?
      source    "settings.php.erb"
      cookbook  'drupal'
    else
      source new_resource.settings_source
      variables ({
        username: new_resource.db_username,
        password: new_resource.db_password,
        database: new_resource.db,
      })
    end
  end

  execute "krafwagen_build" do
    cwd "#{new_resource.root}"
    command "drush kw-b"
    action :run
  end

  settings_compile site_path
  web_app new_resource.uri do
    server_name     uri
    docroot         doc_root
    server_aliases  []
    cookbook        'apache2'
    allow_override  ['All']
  end

  hostsfile_entry '127.0.1.1' do
    hostname  uri
    action    :append
  end

  if new_resource.db_init
    mysql_init new_resource.db_username, new_resource.db_password, new_resource.db
  end
end

def settings_compile(site_path)
  site_conf_d     = "#{site_path}/settings.conf.d"
  ini_conf_d      = "#{site_conf_d}/ini.conf.d"
  globals_conf_d  = "#{site_conf_d}/globals.conf.d"

  [site_conf_d, ini_conf_d, globals_conf_d].each do |dir|
    directory dir do
      owner     new_resource.owner
      group     new_resource.group
      recursive true
    end
  end

  template "#{globals_conf_d}/databases.json" do
    owner   new_resource.owner
    group   new_resource.group
    source  "databases.my.default.json.erb"
    mode    0660
    variables ({
      username: new_resource.db_username,
      password: new_resource.db_password,
      database: new_resource.db,
    })
  end

  template "#{globals_conf_d}/globals.default.json" do
    owner   new_resource.owner
    group   new_resource.group
    source  "globals.default.json.erb"
    mode    0660
  end

end

def mysql_init(user, pass, db)
  mysql_connection = {
    host:     'localhost',
    username: 'root',
    password: node['mysql']['server_root_password']
  }

  mysql_database db do
    connection  mysql_connection
    action      :create
  end

  mysql_database_user user do
    connection    mysql_connection
    password      pass
    database_name db
    action        [:create, :grant]
  end
end
