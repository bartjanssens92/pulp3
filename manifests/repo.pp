#
#
#
class profile_pulp3::repo (
  String $repo_url = 'https://fedorapeople.org/groups/katello/releases/yum/nightly/pulpcore/el$releasever/$basearch/',
) {
  if $repo_url and $repo_url != '' {
    ensure_resource('yumrepo', 'pulp', {
      baseurl  => $repo_url,
      enabled  => 1,
      gpgcheck => 0,
    })
  }
}
