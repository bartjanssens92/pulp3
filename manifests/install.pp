#
#
#
class profile_pulp3::install (
  Boolean              $manage_repo      = $::profile_pulp3::manage_repo,
  String               $pulpcore_package = $::profile_pulp3::pulpcore_package,
  String               $version          = $::profile_pulp3::version,
  String               $admin_password   = $::profile_pulp3::admin_password,
) {

  if $manage_repo {
    include ::profile_pulp3::repo
  }

  package { $pulpcore_package:
    ensure => $version,
  }

  if $facts['os']['selinux']['enabled'] {
    package { 'pulpcore-selinux':
      ensure => present,
    }
  }

  Profile_pulp3::Admin <| tag == 'pulp3_migration' |> -> Service <| tag == 'pulpcore_service' |>

  profile_pulp3::admin  { 'migrate --noinput':
    unless    => 'pulpcore-manager migrate --plan | grep "No planned migration operations"',
    subscribe => Package[$pulpcore_package],
    require   => Systemd::Unit_file['pulpcore-api.service'],
    tag       => 'pulp3_migration',
  }
  profile_pulp3::admin { 'collectstatic --noinput':
    subscribe => Package[$pulpcore_package],
    require   => Systemd::Unit_file['pulpcore-content.service'],
    tag       => 'pulp3_migration',
  }
  profile_pulp3::admin { "reset-admin-password --password ${admin_password}":
    unless    => 'pulpcore-manager dumpdata auth.User | grep "\"username\" : \"admin\""',
    subscribe => Package[$pulpcore_package],
    require   => Profile_pulp3::Admin['migrate --noinput'],
    tag       => 'pulp3_migration',
  }
}
