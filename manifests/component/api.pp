#
#
#
class profile_pulp3::component::api (
  String  $pulp_settings = $::profile_pulp3::pulp_settings,
  String  $pulp_user     = $::profile_pulp3::pulp_user,
  String  $pulp_group    = $::profile_pulp3::pulp_group,
  String  $address       = $::profile_pulp3::api_address,
  Integer $port          = $::profile_pulp3::api_port,
) {

  $_config = {
    'pulp_settings' => $pulp_settings,
    'pulp_user'     => $pulp_user,
    'pulp_group'    => $pulp_group,
    'api_address'   => $address,
    'api_port'      => $port,
  }

  systemd::unit_file { 'pulpcore-api.service':
    content => epp("${module_name}/systemd/pulpcore-api.service", $_config)
  }

  service { 'pulpcore-api':
    ensure    => running,
    enable    => true,
    tag       => 'pulpcore_service',
    subscribe => Systemd::Unit_file['pulpcore-api.service'],
  }
}
