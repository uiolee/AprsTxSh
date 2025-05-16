#!/usr/bin/env bash

DHM_z=$(date -u +"%d%H%Mz")
echo "DHM_z: $DHM_z"

HMS_h=$(date -u +"%H%M%Sh")
echo "HMS_h: $HMS_h"

send_aprs_packet() {
    local DATA=$1

    # https://www.aprs-is.net/APRSServers.aspx

    local APRS_SERVER="http://srvr.aprs-is.net:8080"
    local APRS_SERVER="https://ametx.com:8888"
    local APRS_SERVER="http://rotate.aprs2.net:8080" # NOTE: Not every server supports http/https protocol.
    local APRS_SERVER="http://localhost:8080"

    AUTH_HEADER=$(printf "%s" "$LOGIN_LINE" | base64 | tr -d '\n')

    echo ""
    echo "sending to '$APRS_SERVER'"
    echo "data: "
    printf "$DATA"
    echo -e "\n"

    response=$(
        curl \
            -s \
            -k \
            -w "%{http_code}" \
            -X POST $APRS_SERVER \
            -H "Content-Type: application/octet-stream" \
            -H "Accept: text/plain" \
            -H "Authorization: APRS-IS $AUTH_HEADER" \
            --data-binary "$(printf "$DATA")"
    )

    http_code="${response: -3}"
    body="${response:0:${#response}-3}"

    echo "Response Code: $http_code"
    # echo "Response Body: $body"
    echo "Response Body: $body"
}

SOFTWARE_NAME="AprsTxSh"
SOFTWARE_VERSION="0.1"
SOFTWARE_ID="APZS10"
APRS_PATH="WIDE1-1,WIDE2-2"

CALLSIGN="N0CALL"
PASSCODE="-1"

LOGIN_LINE="user $CALLSIGN pass $PASSCODE vers $SOFTWARE_NAME $SOFTWARE_VERSION"

STATUS_TEXT="Up."

STATUS_PACKET="${CALLSIGN}>$SOFTWARE_ID,$APRS_PATH:>$DHM_z$STATUS_TEXT"

send_aprs_packet "${LOGIN_LINE}\n${STATUS_PACKET}"
