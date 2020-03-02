#
#
#
class profile_pulp3::config (
  String                                    $pulp_db_username    = $::profile_pulp3::pulp_db_username,
  String                                    $pulp_db_password    = $::profile_pulp3::pulp_db_password,
  String                                    $pulp_db_database    = $::profile_pulp3::pulp_db_database,
  Variant[Stdlib::Fqdn, Stdlib::Ip_address] $pulp_db_host        = $::profile_pulp3::pulp_db_host,

  Stdlib::Absolutepath                      $pulp_settings       = $::profile_pulp3::pulp_settings,
  String                                    $pulp_user           = $::profile_pulp3::pulp_user,
  String                                    $pulp_group          = $::profile_pulp3::pulp_group,

  Stdlib::Absolutepath                      $media_root          = $::profile_pulp3::media_root,
  Stdlib::Absolutepath                      $content_path_prefix = $::profile_pulp3::content_path_prefix,
  Optional[String]                          $secret_key          = $::profile_pulp3::secret_key,
  Stdlib::Fqdn                              $hostname            = $::profile_pulp3::hostname,
  Enum['http','https']                      $proto               = $::profile_pulp3::proto,
) {


  # Generate the secret key if not passed
  $_secret_key = pick( $secret_key, fqdn_rand_string('50','abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)'))

  $_base_path = dirname( $pulp_settings )
  exec { $_base_path:
    path    => $::path,
    command => "mkdir -p ${_base_path}",
    unless  => "test -d ${_base_path}",
  }

  $_settings_hash = {
    'pulp_db_database'    => $pulp_db_database,
    'pulp_db_username'    => $pulp_db_username,
    'pulp_db_password'    => $pulp_db_password,
    'pulp_db_host'        => $pulp_db_host,
    'content_path_prefix' => "${content_path_prefix}/",
    'content_origin'      => "${proto}://${hostname}",
    'media_root'          => $media_root,
    'secret_key'          => $_secret_key,
  }

  file { $pulp_settings:
    ensure  => present,
    owner   => $pulp_user,
    group   => $pulp_group,
    content => epp("${module_name}/settings", $_settings_hash)
  }
}
