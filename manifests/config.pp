#
#
#
class profile_pulp3::config (
  Variant[Stdlib::Fqdn, Stdlib::Ip_address] $api_address         = $::profile_pulp3::api_address,
  String                                    $admin_username      = $::profile_pulp3::admin_username,
  String                                    $admin_password      = $::profile_pulp3::admin_password,

  String                                    $pulp_db_username    = $::profile_pulp3::pulp_db_username,
  String                                    $pulp_db_password    = $::profile_pulp3::pulp_db_password,
  String                                    $pulp_db_database    = $::profile_pulp3::pulp_db_database,
  Variant[Stdlib::Fqdn, Stdlib::Ip_address] $pulp_db_host        = $::profile_pulp3::pulp_db_host,
  Integer                                   $pulp_db_port        = $::profile_pulp3::pulp_db_port,

  Variant[Stdlib::Fqdn, Stdlib::Ip_address] $redis_host          = $::profile_pulp3::redis_host,
  Integer                                   $redis_port          = $::profile_pulp3::redis_port,
  Integer[0]                                $redis_db            = $::profile_pulp3::redis_db,

  Stdlib::Absolutepath                      $pulp_settings       = $::profile_pulp3::pulp_settings,
  String                                    $pulp_user           = $::profile_pulp3::pulp_user,
  String                                    $pulp_group          = $::profile_pulp3::pulp_group,

  Stdlib::Absolutepath                      $media_root          = $::profile_pulp3::media_root,
  Stdlib::Absolutepath                      $content_path_prefix = $::profile_pulp3::content_path_prefix,
  Optional[String]                          $secret_key          = $::profile_pulp3::secret_key,
  Stdlib::Fqdn                              $hostname            = $::profile_pulp3::hostname,
  Enum['http','https']                      $proto               = $::profile_pulp3::proto,
  Variant[Stdlib::Fqdn, Stdlib::Ip_address] $content_address     = $::profile_pulp3::content_address,
  Integer                                   $content_port        = $::profile_pulp3::content_port,
) {
  file { 'pulp_mediaroot':
    ensure => directory,
    path   => $media_root,
    owner  => $pulp_user,
    group  => $pulp_group,
    mode   => '0750',
  }

  file { 'pulp_working_directory':
    ensure => directory,
    path   => "${media_root}/tmp",
    owner  => $pulp_user,
    group  => $pulp_group,
    mode   => '0750',
  }

  user { $pulp_user:
    ensure     => present,
    gid        => $pulp_group,
    home       => $media_root,
    managehome => false,
  }

  group { $pulp_group:
    ensure => present,
  }

  # Generate the secret key if not passed
  $_secret_key = pick( $secret_key, fqdn_rand_string('50','abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)'))

  $_base_path = dirname( $pulp_settings )
  file { $_base_path:
    ensure => directory,
    mode   => '0750',
    owner  => 'root',
    group  => $pulp_group,
  }

  $_settings_hash = {
    'pulp_db_database'    => $pulp_db_database,
    'pulp_db_username'    => $pulp_db_username,
    'pulp_db_password'    => $pulp_db_password,
    'pulp_db_host'        => $pulp_db_host,
    'pulp_db_port'        => $pulp_db_port,
    'redis_host'          => $redis_host,
    'redis_port'          => $redis_port,
    'redis_db'            => $redis_db,
    'content_path_prefix' => "${content_path_prefix}/",
    'content_origin'      => "${proto}://${hostname}:${content_port}",
    'media_root'          => $media_root,
    'secret_key'          => $_secret_key,
  }

  file { $pulp_settings:
    ensure  => present,
    owner   => 'root',
    group   => $pulp_group,
    mode    => '0640',
    content => epp("${module_name}/settings", $_settings_hash)
  }

  $_netrc_hash = {
    'api_address'    => $api_address,
    'admin_username' => $admin_username,
    'admin_password' => $admin_password,
  }

  file { '/root/.netrc':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => epp("${module_name}/netrc", $_netrc_hash),
  }
}
