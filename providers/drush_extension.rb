action :create do
    git_url = new_resource.git_url
    extensions_dir = new_resource.extensions_dir ? new_resource.extension_dir : "#{node['drupal']['drush']['root']}/#{node['drupal']['drush']['version']}/commands"
    extension_name = new_resource.extension_name

    git "#{extensions_dir}/#{extension_name}" do
        repository git_url
        action :sync
    end

    execute "drush cc drush" do
        action :run
    end

end
