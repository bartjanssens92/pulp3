#
#
#
class profile_pulp3::component::content (
  String  $pulp_settings = $::profile_pulp3::pulp_settings,
  String  $pulp_user     = $::profile_pulp3::pulp_user,
  String  $pulp_venv_dir = $::profile_pulp3::pulp_venv_dir,
  String  $address       = $::profile_pulp3::content_address,
  Integer $port          = $::profile_pulp3::content_port,
) {

  $_config = {
    'pulp_settings'   => $pulp_settings,
    'pulp_user'       => $pulp_user,
    'pulp_venv_dir'   => $pulp_venv_dir,
    'content_address' => $address,
    'content_port'    => $port,
  }

  systemd::unit_file { 'pulpcore-content.service':
    content => epp("${module_name}/systemd/pulpcore-content.service", $_config)
  }
}
