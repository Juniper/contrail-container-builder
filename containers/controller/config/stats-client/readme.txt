Effort to massively offer Tungsten Fabric as an open-source SDN standard is quite new and require measuring the progress of “conquering” the market - growth rate, community “health”.

The service collects statistics information and sends it to statistics server.
By default the service doesn't collect and send statistics.
Sending settings are checked every hour.

To enable sending:
- go to contrail web UI (https://ip_address:8143) --> Configure tab --> Tags --> Global Tags
( https://ip_address:8143/#p=config_tags_globaltags )
- add tag with type = Label
valid values are:
1. stats_monthly
2. stats_weekly
3. stats_daily

In order to disable sending just remove tags.
In case few tag (misconfiguration) service picks a tag with the least frequency.
