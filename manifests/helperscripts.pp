#
#
#
class profile_pulp3::helperscripts (
  String  $username    = $::profile_pulp3::admin_username,
  String  $password    = $::profile_pulp3::admin_password,
  String  $api_address = $::profile_pulp3::api_address,
  Integer $api_port    = $::profile_pulp3::api_port,
) {

  $helperscripts = [
    'pcurlg',
    'pcurlp',
    'pcurlf',
  ]

  $_credentials = {
    'username'    => $username,
    'password'    => $password,
    'api_address' => $api_address,
    'api_port'    => $api_port,
  }

  package { 'perl-JSON-PP':
    ensure => present,
  }

  $helperscripts.each | $script | {
    file { "/usr/bin/${script}":
      ensure  => present,
      mode    => '0755',
      content => epp("${module_name}/bin/${script}", $_credentials),
    }
  }

}
