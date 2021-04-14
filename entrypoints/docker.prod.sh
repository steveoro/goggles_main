#!/bin/sh

# Fail fast in case of errors:
set -e

# Extract Docker bridge gateway IP and configure SSMTP mailhost accordingly:
MYROUTE=`ip route | grep default`
# (Typical route format: "default via IP_NUM dev DEVICE_NAME proto dhcp metric XYZ")
# Extract the IP part to get the dynamic Gateway address (respect the spacing):
GATEWAY_IP=${MYROUTE##* via }
export GATEWAY_IP=${GATEWAY_IP% dev*}
# $GATEWAY_IP shall hold the actual Gateway IP; substitue default value (localhost) with
# the Gateway, so that we can relay messages outside the container, provided there's a
# submission service listening to the bridge network (typically, Postfix).
sed -i "s/mailhub=.\+/mailhub=$GATEWAY_IP/" /etc/ssmtp/ssmtp.conf

# Don't block server start in case a previous PID file is left:
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

# Start our server and don't use Spring in production:
DISABLE_SPRING=true bundle exec rails s -b 0.0.0.0 -p 8080
