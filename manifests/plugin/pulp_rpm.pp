#
#
#
class profile_pulp3::plugin::pulp_rpm (
  String $package = 'python3-pulp-rpm',
  String $version = '3.5.1-1.el8',
) {

  package { $package:
    ensure => $version
  }
}
