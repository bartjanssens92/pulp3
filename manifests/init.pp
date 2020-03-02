#
#
#
class profile_pulp3 (
  String                                    $admin_password,

  Boolean                                   $setup_postgres      = true,
  Boolean                                   $setup_redis         = true,
  Enum['pypi','rpm','none']                 $install_method      = 'pypi',

  String                                    $admin_username      = 'admin',
  String                                    $pulp_db_username    = 'pulp',
  String                                    $pulp_db_password    = 'pulp',
  String                                    $pulp_db_database    = 'pulp',
  Variant[Stdlib::Fqdn, Stdlib::Ip_address] $pulp_db_host        = $::fqdn,

  Stdlib::Absolutepath                      $pulp_settings       = '/etc/pulp/settings.py',
  Stdlib::Absolutepath                      $pulp_venv_dir       = '/opt/pulp/venv',
  String                                    $pulp_user           = 'root',
  String                                    $pulp_group          = 'root',
  Integer                                   $pulp_workers        = 2,
  Variant[Stdlib::Fqdn, Stdlib::Ip_address] $api_address         = '127.0.0.1',
  Integer                                   $api_port            = 24817,
  Variant[Stdlib::Fqdn, Stdlib::Ip_address] $content_address     = '127.0.0.1',
  Integer                                   $content_port        = 24816,

  Stdlib::Absolutepath                      $content_path_prefix = '/pulp/content',
  Stdlib::Absolutepath                      $media_root          = '/var/lib/pulp',
  Optional[String]                          $secret_key          = undef,
  Stdlib::Fqdn                              $hostname            = $::fqdn,
  Enum['http','https']                      $proto               = 'http',
  Enum['server','manager','worker','aio']   $setup               = 'aio',

  Array                                     $plugins             = ['pulp-rpm'],
) {

  include ::profile_pulp3::helperscripts

  Yumrepo <| |> -> Package <| |>

  if $setup_redis {
    class { 'redis':
      manage_repo => false,
    }
  }

  if $setup_postgres {
    Class['profile_pulp3::postgres'] -> Class["profile_pulp3::install::${install_method}"]
    include ::profile_pulp3::postgres
  }

  class { '::postgresql::client': }

  include ::profile_pulp3::config

  case $setup {
    'server': {
      include "::profile_pulp3::install::${install_method}"
      include ::profile_pulp3::component::api
      include ::profile_pulp3::component::content
    }
    'manager': {
      class {"::profile_pulp3::install::${install_method}":
        migration => false,
      }
      include ::profile_pulp3::component::resource_manager
    }
    'worker': {
      class {"::profile_pulp3::install::${install_method}":
        migration => false,
      }
      include ::profile_pulp3::component::worker
    }
    default: {
      include "::profile_pulp3::install::${install_method}"
      include ::profile_pulp3::component::api
      include ::profile_pulp3::component::content
      include ::profile_pulp3::component::resource_manager
      include ::profile_pulp3::component::worker
    }
  }

  $plugins.each | $plugin | {
    $_plugin = regsubst( $plugin, '-', '_' )
    include "::profile_pulp3::plugin::${_plugin}"
  }
}
