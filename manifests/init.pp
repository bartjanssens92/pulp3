#
#
#
class profile_pulp3 (
  String                                    $admin_password,

  Boolean                                   $setup_postgres      = true,
  Boolean                                   $setup_redis         = true,

  String                                    $admin_username      = 'admin',
  String                                    $pulp_db_username    = 'pulp',
  String                                    $pulp_db_password    = 'pulp',
  String                                    $pulp_db_database    = 'pulp',
  Variant[Stdlib::Fqdn, Stdlib::Ip_address] $pulp_db_host        = 'localhost',
  Integer                                   $pulp_db_port        = 5432,

  Variant[Stdlib::Fqdn, Stdlib::Ip_address] $redis_host          = 'localhost',
  Integer                                   $redis_port          = 6379,
  Integer[0]                                $redis_db            = 1,

  Stdlib::Absolutepath                      $pulp_settings       = '/etc/pulp/settings.py',
  String                                    $pulp_user           = 'pulp',
  String                                    $pulp_group          = 'pulp',
  Integer                                   $pulp_workers        = min(8, $facts['processors']['count']),
  Variant[Stdlib::Fqdn, Stdlib::Ip_address] $api_address         = $facts['networking']['fqdn'],
  Integer                                   $api_port            = 24817,
  Variant[Stdlib::Fqdn, Stdlib::Ip_address] $content_address     = $facts['networking']['fqdn'],
  Integer                                   $content_port        = 24816,

  Stdlib::Absolutepath                      $content_path_prefix = '/pulp/content',
  Stdlib::Absolutepath                      $media_root          = '/var/lib/pulp',
  Optional[String]                          $secret_key          = undef,
  Stdlib::Fqdn                              $hostname            = $::fqdn,
  Enum['http','https']                      $proto               = 'http',
  Enum['server','manager','worker','aio']   $setup               = 'aio',

  Boolean                                   $manage_repo         = false,
  String                                    $pulpcore_package    = 'python3-pulpcore',
  String                                    $version             = 'latest',
  Array                                     $plugins             = ['pulp-rpm'],

  Boolean                                   $manage_firewall     = true,
) {

  include ::profile_pulp3::helperscripts

  Yumrepo <| |> -> Package <| |>

  if $setup_redis {
    class { 'redis':
      manage_repo => false,
    }
  }

  if $setup_postgres {
    Class['profile_pulp3::postgres'] -> Class['profile_pulp3::install']
    include ::profile_pulp3::postgres
  }

  include ::postgresql::client

  include ::profile_pulp3::config

  case $setup {
    'server': {
      include ::profile_pulp3::install
      include ::profile_pulp3::component::api
      include ::profile_pulp3::component::content
      include ::profile_pulp3::plugin
    }
    'manager': {
      class { '::profile_pulp3::install':
        migration => false,
      }
      include ::profile_pulp3::component::resource_manager
    }
    'worker': {
      class {'::profile_pulp3::install':
        migration => false,
      }
      include ::profile_pulp3::component::worker
    }
    default: {
      include ::profile_pulp3::install
      include ::profile_pulp3::component::api
      include ::profile_pulp3::component::content
      include ::profile_pulp3::component::resource_manager
      include ::profile_pulp3::component::worker
      include ::profile_pulp3::plugin
    }
  }

  if $manage_firewall {
    firewall { '100 accecpt pulp content':
      dport  => $content_port,
      proto  => tcp,
      action => accept,
    }
    firewall { '100 accept pulp api':
      dport  => $api_port,
      proto  => tcp,
      action => accept
    }
  }

}
