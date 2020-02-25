#
#
#
class profile_pulp3::helperscripts (
  String $username = $::profile_pulp3::admin_username,
  String $password = $::profile_pulp3::admin_password,
) {

  $helperscripts = [
    'pcurlg',
    'pcurlp',
    'pcurlf',
  ]

  $_credentials = {
    'username' => $username,
    'password' => $password,
  }

  $helperscripts.each | $script | {
    file { "/usr/bin/${script}":
      ensure  => present,
      mode    => '0755',
      content => epp("${module_name}/bin/${script}", $_credentials),
    }
  }

  file { '/usr/bin/bootstrap_pulp3':
    ensure => present,
    mode   => '0755',
    source => "puppet:///modules/${module_name}/bin/bootstrap",
  }
}
