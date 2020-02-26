#
#
#
class profile_pulp3::component::worker (
  String $pulp_settings = $::profile_pulp3::pulp_settings,
  String $pulp_venv_dir = $::profile_pulp3::pulp_venv_dir,
  String $pulp_user     = $::profile_pulp3::pulp_user,
  String $pulp_group    = $::profile_pulp3::pulp_group,
) {

  $_config = {
    'pulp_settings' => $pulp_settings,
    'pulp_user'     => $pulp_user,
    'pulp_group'    => $pulp_group,
    'pulp_venv_dir' => $pulp_venv_dir,
  }

  systemd::unit_file { 'pulpcore-worker@.service':
    content => epp("${module_name}/systemd/pulpcore-worker@.service", $_config)
  }
}
