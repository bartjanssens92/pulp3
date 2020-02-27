#
#
#
class profile_pulp3::install::pypi (
  Stdlib::Absolutepath $venv_path      = $::profile_pulp3::pulp_venv_dir,
  String               $user           = $::profile_pulp3::pulp_user,
  String               $group          = $::profile_pulp3::pulp_group,
  String               $python_version = '3',
  Array                $dependencies   = [],
  String               $pip            = 'pulpcore',
  String               $version        = '3.1.1',
) {

  $_base_path = dirname( $venv_path )
  $_requirements = "${_base_path}/base_requirements.txt"

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

  python::pip { "${venv_path}::${pip}::${version}":
    ensure     => $version,
    pkgname    => $pip,
    virtualenv => $venv_path,
  }

}
