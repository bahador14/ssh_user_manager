#!/bin/bash

# Get a list of active SSH connections on port 22
while true; do
    lsof_output=$(lsof -i :22)
    current_date=$(date +%Y/%m/%d)

    # Read user names, limits, and expire dates from the CSV file
    declare -A user_info
    while IFS=, read -r user limit expire_date; do
        if [ "$user" != "user" ]; then
            user_info["$user"]="$limit:$expire_date"
        fi
    done < user_limits.csv

    for user in "${!user_info[@]}"; do
        limit_and_expire="${user_info[$user]}"
        limit=$(echo "$limit_and_expire" | cut -d ':' -f 1)
        expire_date=$(echo "$limit_and_expire" | cut -d ':' -f 2)

        # Count the user's active SSH connections
        user_connections=$(echo "$lsof_output" | grep -c "$user.*ESTABLISHED")

        if [ "$user_connections" -gt 0 ]; then
            echo "User: $user, Max Connections: $limit, Current Connections: $user_connections, Expire Date: $expire_date"
        fi
        
        if [ "$user_connections" -gt "$limit" ]; then
            # Terminate extra connections for the user
            extra_connections=$(echo "$lsof_output" | grep "$user.*ESTABLISHED" | tail -n +$((limit+1)) | awk '{print $2}')
            for conn in $extra_connections; do
                kill -9 $conn
                echo "Terminating extra connections for user $user"
            done
        fi
        if [ "$current_date" \> "$expire_date" ]; then
            # Terminate all connections for the user
            connections_to_terminate=$(echo "$lsof_output" | grep "$user.*ESTABLISHED" | awk '{print $2}')
            for conn in $connections_to_terminate; do
                kill -9 $conn
                echo "Terminating all connections for user $user"
            done
        fi
    done

    sleep 5   # Wait for 5 seconds
    clear     # Clear the terminal
done
