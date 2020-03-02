#
#
#
class profile_pulp3::install::pypi (
  Stdlib::Absolutepath $venv_path      = $::profile_pulp3::pulp_venv_dir,
  String               $user           = $::profile_pulp3::pulp_user,
  String               $group          = $::profile_pulp3::pulp_group,
  Stdlib::Absolutepath $settings       = $::profile_pulp3::pulp_settings,
  String               $password       = $::profile_pulp3::admin_password,
  String               $python_version = '3',
  Array                $dependencies   = [],
  String               $pip            = 'pulpcore',
  String               $version        = '3.1.1',
  Boolean              $migration      = true,
) {

  $_base_path = dirname( $venv_path )

  exec { $_base_path:
    path    => $::path,
    command => "mkdir -p ${_base_path}",
    unless  => "test -d ${_base_path}",
  }

  package { 'python36-virtualenv':
    ensure => present,
  }

  package { $dependencies:
    ensure => present,
  }

  class { 'python':
    use_epel => false,
  }

  python::virtualenv { $venv_path:
    ensure       => present,
    version      => $python_version,
    distribute   => false,
    systempkgs   => true,
    virtualenv   => 'virtualenv-3',
    owner        => $user,
    group        => $group,
    require      => [
      Exec[$_base_path],
    ],
  }

  Python::Pip <| |> {
    pip_provider => 'pip',
    virtualenv   => $venv_path,
  }

  python::pip { "${venv_path}::${pip}::${version}":
    ensure  => $version,
    pkgname => $pip,
    require => Package[$dependencies],
  }

  Exec {
    path        => "${venv_path}/bin:${::path}",
    environment => [
      'DJANGO_SETTINGS_MODULE=pulpcore.app.settings',
      "PULP_SETTINGS=${settings}",
      "LD_LIBRARY_PATH=${pulp_venv_dir}/lib64",
    ],
  }

  if $migration {

    Exec <| tag == 'pulp3_migration' |> -> Service <| tag == 'pulpcore_service' |>

    exec { 'Initial_migration':
      command     => 'django-admin migrate --noinput',
      tag         => 'pulp3_migration',
      refreshonly => true,
      subscribe   => Python::Pip["${venv_path}::${pip}::${version}"],
      require     => Systemd::Unit_file['pulpcore-api.service'],
    }

    exec { 'collectstatic':
      command => 'django-admin collectstatic --noinput',
      tag         => 'pulp3_migration',
      refreshonly => true,
      subscribe   => Python::Pip["${venv_path}::${pip}::${version}"],
      require     => Systemd::Unit_file['pulpcore-content.service'],
    }

    $vardir = '/opt/puppetlabs/puppet/cache/client_data'

    file { "${vardir}/pulp_admin":
      ensure  => present,
      mode    => '0600',
      content => sha256($password),
    }

    exec { 'Set_admin_pw':
      command     => "django-admin reset-admin-password --password ${password}",
      tag         => 'pulp3_migration',
      refreshonly => true,
      require     => Systemd::Unit_file['pulpcore-api.service'],
      subscribe   => [
        File["${vardir}/pulp_admin"],
        Python::Pip["${venv_path}::${pip}::${version}"],
      ],
    }
  }
}
