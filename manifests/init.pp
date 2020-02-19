#
#
#
class profile_pulp3 (
  Stdlib::Absolutepath $media_root = '/var/lib/pulp',
  Optional[String]     $secret_key = undef,
  Boolean              $setup_postgres   = true,
  String               $pulp_db_username = 'pulp',
  String               $pulp_db_password = 'pulp',
  String               $pulp_db_database = 'pulp',
  String               $pulp_db_host     = 'localhost',
) {

  # Generate the secret key if not passed
  if ! $secret_key {
    $_secret_key = fqdn_rand_string('50','abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)')
  } else {
    $_secret_key = $secret_key
  }

  include ::redis

  # Database
  if $setup_postgres {
    class { '::postgresql::globals':
      encoding            => 'UTF-8',
      manage_package_repo => true,
      version             => '10',
    }

    -> class { '::postgresql::server':
      ip_mask_allow_all_users => '0.0.0.0/32',
      listen_addresses        => 'localhost',
    }

    postgresql::server::db { $pulp_db_database:
      user     => $pulp_db_username,
      password => $pulp_db_password,
      grant    => 'all',
    }

    postgresql::server::pg_hba_rule { $pulp_db_database:
      type        => 'local',
      database    => $pulp_db_database,
      user        => $pulp_db_username,
      auth_method => 'md5',
    }
  }

  class { '::postgresql::client': }

  # packages for building atm
  $packages = [
    'postgresql-devel-9.2.24-2.el7_7.x86_64',
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
    'python3',
  ]

  package { $packages:
    ensure => present,
  }

  # systemd files for dev
  $systemd_files = [
    'pulpcore-resource-manager.service',
    'pulpcore-api.service',
    'pulpcore-content.service',
    'pulpcore-worker@.service',
    'pulp-rpm-gunicorn.service',
  ]

  $systemd_files.each | $systemd_file | {
    systemd::unit_file { $systemd_file:
      source => "puppet:///modules/${module_name}/systemd/${systemd_file}",
    }
  }

  file { '/etc/pulp':
    ensure => directory,
  }

  $settings_hash = {
    'media_root'       => $media_root,
    'secret_key'       => $_secret_key,
    'pulp_db_database' => $pulp_db_database,
    'pulp_db_username' => $pulp_db_username,
    'pulp_db_password' => $pulp_db_password,
    'pulp_db_host'     => $pulp_db_host,
  }

  file { '/etc/pulp/settings.py':
    ensure  => present,
    content => epp('profile_pulp3/settings', $settings_hash)
  }

  file { '/opt/pulp':
    ensure => directory,
  }

  $helperscripts = [
    'pcurlg',
    'pcurlp',
    'pcurlf',
  ]
  $helperscripts.each | $script | {
    file { "/usr/bin/${script}":
      ensure => present,
      mode   => '0755',
      source => "puppet:///modules/${module_name}/bin/${script}",
    }
  }

  #file { '/usr/bin/bootstrap_pulp3':
  #  ensure => present,
  #  mode   => '0755',
  #  source => "puppet:///modules/${module_name}/bin/bootstrap",
  #}

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
