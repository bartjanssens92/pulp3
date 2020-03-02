#
#
#
class profile_pulp3::plugin::pulp_rpm (
  String $version = 'present',
  String $pip     = 'pulp-rpm',
) {

  $dependencies = [
    'libmodulemd2-devel',
    'python36-gobject',
  ]

  package { $dependencies:
    ensure => present,
  }

  python::pip { "${pip}::${version}":
    ensure  => $version,
    pkgname => $pip,
  }

  #  file { "${pulp_dir}/venv/pyvenv.cfg":
  #    ensure  => present,
  #    content => 'home = /bin
  #include-system-site-packages = true
  #version = 3.6.8',
  #  }
}
