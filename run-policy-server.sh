#!/bin/bash -u

#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Path to src tree
PREFIX=$1
# Do not change the server name
POLSRVR=AdvPolicyServer

# Stop YARN....
sudo ydown
sleep 0.1

# Kill any currently running policy servers....
sudo killall $POLSRVR
sleep 0.1
# Make sure of it
sudo fuser -k -n tcp 9091
sleep 0.1

# Purge old log files....
sudo rm -f /tmp/AdvPolicyServer.log
sudo rm -f /tmp/AdvPolicyServer.out

sudo rm -f /srv/yarn/results.txt
sleep 0.1

export MY_CONFIG="$(cd `dirname $0` && pwd -P)/job-conf-r4.4xlarge.json"

if [ ! -f $PREFIX/$POLSRVR ] ; then
    echo "FATAL: $POLSRVR binary not built... exit"
    exit 1
fi

if [ ! -f $MY_CONFIG ] ; then
    echo "FATAL: $MY_CONFIG not found... exit"
    exit 1
fi

# Restart YARN....
sudo yup
echo ""
echo ""
sleep 0.1

# Start a new policy server daemon
echo "Starting policy server..."
nohup $PREFIX/$POLSRVR </dev/null 1>/tmp/AdvPolicyServer.out 2>/tmp/AdvPolicyServer.log &
echo "Using job conf $MY_CONFIG"
echo "Redirecting stdout to /tmp/AdvPolicyServer.out..."
echo "Redirecting stderr to /tmp/AdvPolicyServer.log..."
sleep 0.1

echo ""
echo "OK - running in background"
echo "--------------------"
echo "!!! POLSRVR UP !!!"

exit 0
