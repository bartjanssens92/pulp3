#
#
#
class profile_pulp3::component::worker (
  String  $pulp_settings = $::profile_pulp3::pulp_settings,
  String  $pulp_user     = $::profile_pulp3::pulp_user,
  String  $pulp_group    = $::profile_pulp3::pulp_group,
  Integer $pulp_workers  = $::profile_pulp3::pulp_workers,
) {

  $_config = {
    'pulp_settings' => $pulp_settings,
    'pulp_user'     => $pulp_user,
    'pulp_group'    => $pulp_group,
  }

  systemd::unit_file { 'pulpcore-worker@.service':
    content => epp("${module_name}/systemd/pulpcore-worker@.service", $_config)
  }

  $_workers = profile_pulp3::generate_workers($pulp_workers)
  $_workers.each | $i | {
    service { "pulpcore-worker@${i}":
      ensure    => running,
      enable    => true,
      tag       => 'pulpcore_service',
      subscribe => Systemd::Unit_file['pulpcore-worker@.service'],
    }
  }
}
