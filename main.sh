#!/usr/bin/env bash
# Starlink Full Interactive API Terminal GUI
# Made By Taylor Christian Newsome
# Dependencies: bash, dialog, curl, jq, iproute2

# Dependencies check
for cmd in dialog curl jq ip; do
    if ! command -v $cmd &>/dev/null; then
        echo "$cmd is required. Install it first."
        exit 1
    fi
done

# Function to detect Starlink router IP automatically
detect_starlink_ip() {
    # Most Starlink routers are on the same LAN as the default route
    GW=$(ip route | grep default | awk '{print $3}')
    if [[ -z "$GW" ]]; then
        echo "Cannot detect router IP automatically. Please enter manually:"
        read -rp "Starlink router IP: " GW
    fi
    echo "$GW"
}

STARLINK_IP=$(detect_starlink_ip)
STARLINK_API="http://$STARLINK_IP"

# Generic helper function to call API (GET)
call_api() {
    local endpoint=$1
    clear
    echo "Calling $endpoint ..."
    curl -s "$STARLINK_API$endpoint" | jq
    echo -e "\nPress Enter to return to menu..."
    read
}

# Helper function to get public IP
get_public_ip() {
    clear
    echo "Fetching public IP..."
    curl -s https://ifconfig.me
    echo -e "\nPress Enter to continue..."
    read
}

# Enable bridge mode (mock POST)
enable_bridge_mode() {
    clear
    echo "Attempting to enable bridge mode..."
    curl -s -X POST "$STARLINK_API/api/accounts/v1/accounts/default-config/router" \
        -H "Content-Type: application/json" \
        -d '{"bypass_mode":true}' | jq
    echo -e "\nBridge mode command sent. Verify via router GUI."
    echo "Press Enter to continue..."
    read
}

# Show active UTs
show_active_uts() {
    call_api "/api/accounts/v1/accounts/active-uts/"
}

# Show router config
show_router_config() {
    call_api "/api/accounts/v1/device-config/router/config/"
}

# Show device config
show_device_config() {
    call_api "/api/accounts/v1/device-config/user-terminal/config/"
}

# Main interactive menu
while true; do
CHOICE=$(dialog --clear --backtitle "Starlink Full Interactive GUI - Made By Taylor Christian Newsome" \
    --title "Main Menu" \
    --menu "Choose an option:" 30 100 15 \
    1 "Show public IP" \
    2 "Show LAN info" \
    3 "Show active UTs" \
    4 "Show router config" \
    5 "Show device config" \
    6 "Enable bridge mode" \
    7 "Call Starlink API Endpoints" \
    8 "Exit" \
    2>&1 >/dev/tty)

clear
case $CHOICE in
    1) get_public_ip ;;
    2) ip addr show; echo -e "\nPress Enter to continue..."; read ;;
    3) show_active_uts ;;
    4) show_router_config ;;
    5) show_device_config ;;
    6) enable_bridge_mode ;;
    7)
        # Submenu for full API endpoints
        ENDPOINT_CHOICE=$(dialog --clear --backtitle "Starlink API Endpoints - Made By Taylor Christian Newsome" \
            --title "API Endpoints" \
            --menu "Select an API endpoint:" 40 100 20 \
            1 "/api" \
            2 "/api/accounts" \
            3 "/api/accounts/v1/accounts" \
            4 "/api/accounts/v1/accounts/account-managed-asset-classes" \
            5 "/api/accounts/v1/accounts/account-numbers/" \
            6 "/api/accounts/v1/accounts/active-uts/" \
            7 "/api/accounts/v1/accounts/as-user" \
            8 "/api/accounts/v1/accounts/by-address/" \
            9 "/api/accounts/v1/accounts/bynumber/" \
            10 "/api/accounts/v1/accounts/bysubjectid/" \
            11 "/api/accounts/v1/accounts/contact/" \
            12 "/api/accounts/v1/accounts/customer-details/" \
            13 "/api/accounts/v1/accounts/customer-details/to-reactivate" \
            14 "/api/accounts/v1/accounts/customer-details/to-suspend" \
            15 "/api/accounts/v1/accounts/default-config/router" \
            16 "/api/accounts/v1/accounts/handle-additional-details" \
            17 "/api/accounts/v1/accounts/handle-redirect" \
            18 "/api/accounts/v1/accounts/parent-accounts" \
            19 "/api/accounts/v1/accounts/service-lines-by-ut/" \
            20 "/api/accounts/v1/accounts/service-order/" \
            21 "/api/accounts/v1/accounts/service-order/by-account-number/" \
            22 "/api/accounts/v1/accounts/starlink-handle-redirect" \
            23 "/api/accounts/v1/accounts/starpay-handle-redirect" \
            24 "/api/accounts/v1/accounts/user-content" \
            25 "/api/accounts/v1/accounts/ut-by-search-string/" \
            26 "/api/accounts/v1/aviation-metadata" \
            27 "/api/accounts/v1/calculon-base-rule" \
            28 "/api/accounts/v1/calculon-base-rule/fetch/" \
            29 "/api/accounts/v1/community-pass/unsandbox" \
            30 "/api/accounts/v1/device-config/account//routers?limit=1000&page=0" \
            31 "/api/accounts/v1/device-config/router/" \
            32 "/api/accounts/v1/device-config/router/config/" \
            33 "/api/accounts/v1/device-config/user-terminal/" \
            34 "/api/accounts/v1/device-config/user-terminal/config/" \
            35 "/api/accounts/v1/service-bulletin/" \
            36 "/api/accounts/v2/accounts" \
            37 "/api/accounts/v2/accounts/contact" \
            38 "/api/accounts/v2/accounts/uts-with-no-data/" \
            39 "/api/accounts/v3/accounts/uts-with-no-data/" \
            40 "Back to main menu" \
            2>&1 >/dev/tty)
        
        if [[ $ENDPOINT_CHOICE -ge 1 && $ENDPOINT_CHOICE -le 39 ]]; then
            case $ENDPOINT_CHOICE in
                1) call_api "/api" ;;
                2) call_api "/api/accounts" ;;
                3) call_api "/api/accounts/v1/accounts" ;;
                4) call_api "/api/accounts/v1/accounts/account-managed-asset-classes" ;;
                5) call_api "/api/accounts/v1/accounts/account-numbers/" ;;
                6) call_api "/api/accounts/v1/accounts/active-uts/" ;;
                7) call_api "/api/accounts/v1/accounts/as-user" ;;
                8) call_api "/api/accounts/v1/accounts/by-address/" ;;
                9) call_api "/api/accounts/v1/accounts/bynumber/" ;;
                10) call_api "/api/accounts/v1/accounts/bysubjectid/" ;;
                11) call_api "/api/accounts/v1/accounts/contact/" ;;
                12) call_api "/api/accounts/v1/accounts/customer-details/" ;;
                13) call_api "/api/accounts/v1/accounts/customer-details/to-reactivate" ;;
                14) call_api "/api/accounts/v1/accounts/customer-details/to-suspend" ;;
                15) call_api "/api/accounts/v1/accounts/default-config/router" ;;
                16) call_api "/api/accounts/v1/accounts/handle-additional-details" ;;
                17) call_api "/api/accounts/v1/accounts/handle-redirect" ;;
                18) call_api "/api/accounts/v1/accounts/parent-accounts" ;;
                19) call_api "/api/accounts/v1/accounts/service-lines-by-ut/" ;;
                20) call_api "/api/accounts/v1/accounts/service-order/" ;;
                21) call_api "/api/accounts/v1/accounts/service-order/by-account-number/" ;;
                22) call_api "/api/accounts/v1/accounts/starlink-handle-redirect" ;;
                23) call_api "/api/accounts/v1/accounts/starpay-handle-redirect" ;;
                24) call_api "/api/accounts/v1/accounts/user-content" ;;
                25) call_api "/api/accounts/v1/accounts/ut-by-search-string/" ;;
                26) call_api "/api/accounts/v1/aviation-metadata" ;;
                27) call_api "/api/accounts/v1/calculon-base-rule" ;;
                28) call_api "/api/accounts/v1/calculon-base-rule/fetch/" ;;
                29) call_api "/api/accounts/v1/community-pass/unsandbox" ;;
                30) call_api "/api/accounts/v1/device-config/account//routers?limit=1000&page=0" ;;
                31) call_api "/api/accounts/v1/device-config/router/" ;;
                32) call_api "/api/accounts/v1/device-config/router/config/" ;;
                33) call_api "/api/accounts/v1/device-config/user-terminal/" ;;
                34) call_api "/api/accounts/v1/device-config/user-terminal/config/" ;;
                35) call_api "/api/accounts/v1/service-bulletin/" ;;
                36) call_api "/api/accounts/v2/accounts" ;;
                37) call_api "/api/accounts/v2/accounts/contact" ;;
                38) call_api "/api/accounts/v2/accounts/uts-with-no-data/" ;;
                39) call_api "/api/accounts/v3/accounts/uts-with-no-data/" ;;
            esac
        fi
        ;;
    8) clear; exit 0 ;;
    *) echo "Invalid option"; sleep 1 ;;
esac
done
