#
#
#
class profile_pulp3::plugin::pulp_rpm (
  String               $pip          = 'pulp-rpm',
  String               $version      = '3.1.0',
  Stdlib::Absolutepath $venv_path    = $::profile_pulp3::pulp_venv_dir,
  Stdlib::Absolutepath $settings     = $::profile_pulp3::pulp_settings,
  Array                $dependencies = [],
) {

  package { $dependencies:
    ensure => present,
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
      "LD_LIBRARY_PATH=${venv_path}/lib64",
    ],
  }

  exec { 'pulp-rpm_migration':
    command     => 'django-admin migrate rpm',
    tag         => 'pulp3_migration',
    refreshonly => true,
    subscribe   => Python::Pip["${venv_path}::${pip}::${version}"],
  }
}
