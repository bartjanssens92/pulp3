#
#
#
class profile_pulp3::component::resource_manager (
  String $pulp_settings = $::profile_pulp3::pulp_settings,
  String $pulp_user     = $::profile_pulp3::pulp_user,
  String $pulp_venv_dir = $::profile_pulp3::pulp_venv_dir,
) {

  $_config = {
    'pulp_settings' => $pulp_settings,
    'pulp_user'     => $pulp_user,
    'pulp_venv_dir' => $pulp_venv_dir,
  }

  systemd::unit_file { 'pulpcore-resource-manager.service':
    content => epp("${module_name}/systemd/pulpcore-resource-manager.service", $_config)
  }

  service { 'pulpcore-resource-manager':
    ensure    => running,
    tag       => 'pulpcore_service',
    subscribe => Systemd::Unit_file['pulpcore-resource-manager.service'],
  }
}
