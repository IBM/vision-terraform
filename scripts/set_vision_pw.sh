#!/bin/bash -e

BASEDIR="$(dirname "$0")"
# shellcheck disable=SC1090
source ${BASEDIR}/env.sh

echo "Setting PowerAI Vision password..."
echo "Waiting for authorization services to start up..."

RETRYCOUNT=0
RETRYDELAY=120
MAXRETRIES=5 #300 seconds, or 5 minutes
until /opt/powerai-vision/bin/kubectl.sh wait --for=condition=available deployment/powerai-vision-keycloak --timeout=${RETRYDELAY}s; do
  RETRYCOUNT=$((RETRYCOUNT + 1))
  if [ "${RETRYCOUNT}" -eq "${MAXRETRIES}" ]; then
    echo "ERROR: Keycloak deployment failed to become available within ${MAXRETRIES} attempts of checking."
    exit 1
  fi
done


/opt/powerai-vision/bin/kubectl.sh run --rm -i --restart=Never usermgt --image=${USERMGTIMAGE} -- modify --user admin --password $1
echo "PowerAI Vision password set!"
