# git '/var/drupals/foo' do
#   repository  'http://git.drupal.org/project/drupal.git'
#   reference   '8.x'
#   action      :sync
#   user        'vagrant'
#   group       'www-data'
# end

drupal_site 'kw' do
  root        '/var/drupals/kw'
  db          'fooDB'
  db_username 'fooDBA'
  db_password 'fooPASS'
  db_init     true
  provider    :drupal_kw_site
end
