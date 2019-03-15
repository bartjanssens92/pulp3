# Profile_pulp3

Also read a collection of things needed to spin up a pulp3 instance.

*Disclaimer*

Very early stage of development, don't use for production!

All-in-one:

include ::profile_pulp3

This class will setup a postgres and redis servers for pulp to use.
It will also use the bootstrap script to setup a pulp instance with the rpm plugin.
