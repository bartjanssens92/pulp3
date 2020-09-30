# Profile_pulp3

The module manages the installation of pulp3 with the rpm plugin.

Also read a collection of things needed to spin up a pulp3 instance.

*Disclaimer*

Very early stage of development, don't use for production!

All-in-one:

include ::profile_pulp3

This class will setup a postgres and redis servers for pulp to use.

Now managing the installation of pulpcore with the rpm packages using the katello repository.
