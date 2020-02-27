#
#
#
class profile_pulp3 (
  String                                    $admin_password,

  Boolean                                   $setup_postgres   =  true,
  Boolean                                   $setup_redis      =  true,

  String                                    $admin_username   =  'admin',
  String                                    $pulp_db_username =  'pulp',
  String                                    $pulp_db_password =  'pulp',
  String                                    $pulp_db_database =  'pulp',
  Variant[Stdlib::Fqdn, Stdlib::Ip_address] $pulp_db_host     =  $::fqdn,

  Stdlib::Absolutepath                      $pulp_settings    =  '/etc/pulp/settings.py',
  Stdlib::Absolutepath                      $pulp_venv_dir    =  '/opt/pulp/venv',
  String                                    $pulp_user        =  'root',
  String                                    $pulp_group       =  'root',
  Variant[Stdlib::Fqdn, Stdlib::Ip_address] $api_address      =  '127.0.0.1',
  Integer                                   $api_port         =  24817,
  Variant[Stdlib::Fqdn, Stdlib::Ip_address] $content_address  =  '127.0.0.1',
  Integer                                   $content_port     =  24816,

  Stdlib::Absolutepath                      $media_root       =  '/var/lib/pulp',
  Optional[String]                          $secret_key       =  undef,
  Stdlib::Fqdn                              $hostname         =  $::fqdn,
  Enum['http','https']                      $proto            =  'http',
  Enum['server','manager','worker','aio']   $setup            = 'aio',

  Array                                     $plugins          = ['pulp-rpm'],
) {

  # Generate the secret key if not passed
  $_secret_key = pick( $secret_key, fqdn_rand_string('50','abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)'))

  include ::profile_pulp3::helperscripts

  if $setup_redis {
    include ::redis
  }

  $plugins.each | $plugin | {
    $_plugin = regsubst( $plugin, '-', '_' )
    include "::profile_pulp3::plugin::${_plugin}"
  }


  case $setup {
    'server': {
      include ::profile_pulp3::component::api
      include ::profile_pulp3::component::content
    }
    'manager': {
      include ::profile_pulp3::component::resource_manager
    }
    'worker': {
      include ::profile_pulp3::component::worker
    }
    default: {
      include ::profile_pulp3::component::api
      include ::profile_pulp3::component::content
      include ::profile_pulp3::component::resource_manager
      include ::profile_pulp3::component::worker
    }
  }

  # Database
  if $setup_postgres {
    include ::profile_pulp3::postgres
  }

  class { '::postgresql::client': }

  include ::profile_pulp3::install::pypi

  #file { '/opt/pulp':
  #  ensure => directory,
  #}

  # packages for building atm
  $packages = [
    'postgresql-devel',
    'python36',
    'git',
    'tig',
    'gcc',
    'make',
    'cmake',
    'bzip2-devel',
    'expat-devel',
    'file-devel',
    'glib2-devel',
    'libcurl-devel',
    'libxml2-devel',
    'python36-devel',
    'rpm-devel',
    'openssl-devel',
    'sqlite-devel',
    'xz-devel',
    'zchunk-devel',
    'zlib-devel',
  ]

  #package { $packages:
  #  ensure => present,
  #}

  file { '/etc/pulp':
    ensure => directory,
  }

  $db_settings = {
    'pulp_db_database' => $pulp_db_database,
    'pulp_db_username' => $pulp_db_username,
    'pulp_db_password' => $pulp_db_password,
    'pulp_db_host'     => $pulp_db_host,
  }
  $content_settings = {
    'content_path_prefix' => '/pulp/content/',
    'content_origin'      => "${proto}://${hostname}",
  }
  $media_settings = {
    'media_root' => $media_root,
  }
  $settings_hash = {
    'secret_key' => $_secret_key,
  }

  file { '/etc/pulp/settings.py':
    ensure  => present,
    content => epp("${module_name}/settings", $db_settings + $content_settings + $media_settings + $settings_hash )
  }

  #exec { 'bootstrap::pulp3':
  #  path    => $::path,
  #  command => '/usr/bin/bootstrap_pulp3',
  #  creates => '/opt/pulp/pulpvenv/bin/activate',
  #  timeout => 0,
  #  require => [
  #    Package[$packages],
  #    File['/opt/pulp'],
  #    File['/etc/pulp/settings.py'],
  #    File['/usr/bin/bootstrap_pulp3'],
  #    Service['redis'],
  #  ],
  #}
}
