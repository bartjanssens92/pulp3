#
#
#
class profile_pulp3::rpm () {

  $dependencies = [
    'libmodulemd2-devel',
    'python36-gobject',
  ]

  package { $dependencies:
    ensure => present,
  }

  file { "${pulp_dir}/venv/pyvenv.cfg":
    ensure  => present,
    content => 'home = /bin
include-system-site-packages = true
version = 3.6.8',
  }
}
