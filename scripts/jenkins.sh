#!/bin/bash
set -e

[ -f " /tmp/jq" ] || curl --silent -L https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 > /tmp/jq 
chmod 755 /tmp/jq

echo "[$(date +%FT%T)+00:00] Launching flood"
flood_uuid=$(curl --silent -u $FLOOD_API_TOKEN: -X POST https://api.flood.io/floods \
  -F "flood[tool]=jmeter" \
  -F "flood[threads]=100" \
  -F "flood[rampup]=30" \
  -F "flood[duration]=120" \
  -F "flood[privacy]=public" \
  -F "flood[name]=CI Build $BUILD_NUMBER" \
  -F "flood[tag_list]=ci,shakeout" \
  -F "flood_files[]=@$JENKINS_HOME/floods/ruby-jmeter.jmx" | /tmp/jq -r ".uuid")
   
echo "[$(date +%FT%T)+00:00] Waiting for flood https://flood.io/$flood_uuid to finish"
while [ $(curl --silent --user $FLOOD_API_TOKEN: https://api.flood.io/floods/$flood_uuid | \
  /tmp/jq -r '.status == "finished"') = "false" ]; do
  sleep 3
done

flood_report=$(curl --silent --user $FLOOD_API_TOKEN: https://api.flood.io/floods/$flood_uuid/report | \
  /tmp/jq -r ".summary")

echo
echo "[$(date +%FT%T)+00:00] Detailed results at https://flood.io/$flood_uuid"
echo "$flood_report"

