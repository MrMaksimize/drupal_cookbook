
drupal_site 'kw' do
  root        '/var/drupals/kw'
  db          'fooDB'
  db_username 'fooDBA'
  db_password 'fooPASS'
  db_init     true
  provider    :drupal_kw_site
end
