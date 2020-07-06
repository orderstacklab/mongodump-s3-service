#!/bin/bash
echo "$CRON_EXPRESSION /bin/bash /usr/local/bin/myawesomescript" > /etc/crontabs/root
echo $@
exec $@