#
#
# 
define profile_pulp3::admin (
  String                      $command       = $title,
  Boolean                     $refreshonly   = true,
  Optional[String]            $unless        = undef,
  Array[Stdlib::Absolutepath] $path          = ['/bin'],
  String                      $user          = $profile_pulp3::pulp_user,
  Stdlib::Absolutepath        $pulp_settings = $profile_pulp3::pulp_settings,
) {
  Concat <| title == 'pulpcore settings' |>
  -> exec { "pulpcore-manager ${command}" :
    user        => $user,
    path        => $path,
    environment => ["PULP_SETTINGS=${pulp_settings}"],
    refreshonly => $refreshonly,
    unless      => $unless,
  }
}
