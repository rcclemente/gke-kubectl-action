#!/bin/sh

set -e

if [ ! -d "$HOME/.config/gcloud" ]; then
   if [ -z "${APPLICATION_CREDENTIALS-}" ]; then
      echo "APPLICATION_CREDENTIALS not found. Exiting...."
      exit 1
   fi

   if [ -z "${PROJECT_ID-}" ]; then
      echo "PROJECT_ID not found. Exiting...."
      exit 1
   fi

   if [ -z "${REGION-}" && -z "${ZONE_NAME-}" ]; then
      echo "REGION and/or ZONE_NAME not found. Exiting...."
      exit 1
   fi

   echo "$APPLICATION_CREDENTIALS" | base64 -d > /tmp/account.json

   gcloud auth activate-service-account --key-file=/tmp/account.json --project "$PROJECT_ID"

fi

echo ::add-path::/google-cloud-sdk/bin/gcloud
echo ::add-path::/google-cloud-sdk/bin/gsutil

# Update kubeConfig.
LOCATION=""
if [[ -z "${REGION-}"]]; then LOCATION="$LOCATION --region $REGION"; fi
if [[ -z "${ZONE_NAME-}"]]; then LOCATION="$LOCATION --zone $ZONE_NAME"; fi

gcloud container clusters get-credentials "$CLUSTER_NAME" --project "$PROJECT_ID" $LOCATION


# verify kube-context
kubectl config current-context

sh -c "kubectl $*"
