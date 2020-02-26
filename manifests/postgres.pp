#
#
#
class profile_pulp3::postgres (
  String $pulp_db_username = $::profile_pulp3::pulp_db_username,
  String $pulp_db_password = $::profile_pulp3::pulp_db_password,
  String $pulp_db_database = $::profile_pulp3::pulp_db_database,
) {

  class { '::postgresql::globals':
    encoding            => 'UTF-8',
    manage_package_repo => true,
    version             => '10',
  }

  -> class { '::postgresql::server':
    ip_mask_allow_all_users => '0.0.0.0/32',
    listen_addresses        => 'localhost',
  }

  postgresql::server::db { $pulp_db_database:
    user     => $pulp_db_username,
    password => $pulp_db_password,
    grant    => 'all',
  }

  postgresql::server::pg_hba_rule { $pulp_db_database:
    type        => 'local',
    database    => $pulp_db_database,
    user        => $pulp_db_username,
    auth_method => 'md5',
  }

  postgresql::server::pg_hba_rule { "${pulp_db_database}_${::fqdn}":
    type        => 'host',
    database    => $pulp_db_database,
    user        => $pulp_db_username,
    address     => $::fqdn,
    auth_method => 'md5',
  }
}
