#
#
#
class profile_pulp3::component::content (
  String  $pulp_settings = $::profile_pulp3::pulp_settings,
  String  $pulp_user     = $::profile_pulp3::pulp_user,
  String  $pulp_group    = $::profile_pulp3::pulp_group,
  String  $address       = $::profile_pulp3::content_address,
  Integer $port          = $::profile_pulp3::content_port,
) {

  $_config = {
    'pulp_settings'   => $pulp_settings,
    'pulp_user'       => $pulp_user,
    'pulp_group'    => $pulp_group,
    'content_address' => $address,
    'content_port'    => $port,
  }

  systemd::unit_file { 'pulpcore-content.service':
    content => epp("${module_name}/systemd/pulpcore-content.service", $_config)
  }

  service { 'pulpcore-content':
    ensure    => running,
    enable    => true,
    tag       => 'pulpcore_service',
    subscribe => Systemd::Unit_file['pulpcore-content.service'],
  }
}
