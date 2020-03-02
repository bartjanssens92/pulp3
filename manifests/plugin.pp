#
#
#
class profile_pulp3::plugin (
  Array $plugins = $::profile_pulp3::plugins,
) {
  $plugins.each | $plugin | {
    $_plugin = regsubst( $plugin, '-', '_' )
    include "::profile_pulp3::plugin::${_plugin}"
  }
}
