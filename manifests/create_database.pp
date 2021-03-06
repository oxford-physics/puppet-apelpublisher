class apelpublisher::create_database (
  $mysql_database            = $apelpublisher::params::mysql_database,
  $mysql_user                = $apelpublisher::params::mysql_user,
  $mysql_root_password       = $apelpublisher::params::mysql_root_password,
  $mysql_apel_password       = $apelpublisher::params::mysql_apel_password,
  $list_of_apel_parser_hosts = $apelpublisher::params::list_of_apel_parser_hosts,) inherits apelpublisher::params {
  mysql::db { $mysql_database:
    user     => $mysql_user,
    password => $mysql_apel_password
  }

  $permission_defaults = {
    'mysql_user'     => $mysql_user,
    'mysql_database' => $mysql_database,
  }

  if $list_of_apel_parser_hosts {
    create_resources('apelpublisher::db_permissions', $list_of_apel_parser_hosts, $permission_defaults)
  }

  exec { 'create-apel-mysql-tables':
    command => '/usr/bin/mysql --defaults-file=/root/.my.cnf apelclient < /usr/share/apel/client.sql',
    require => [
#      Class["apelpublisher::install"],
      Mysql_database[$mysql_database]],
    # needs check if already exists, otherwise will wipe the tables!
    onlyif  => [
      '/usr/bin/test `/usr/bin/mysql --defaults-file=/root/.my.cnf -e "use apelclient; show tables;SELECT FOUND_ROWS();" 2>&1 | cut -f1 | egrep "^(0|[1-9][0-9]*)$"` -eq 0',
      '/usr/bin/test -f /usr/share/apel/client.sql'],
  }
}
