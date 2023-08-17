#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 username password limit expire_date (yyyy/mm/dd)"
    exit 1
fi

username="$1"
password="$2"
limit="$3"
expire_date="$4"

# Check if the expire_date is in the correct format (yyyy/mm/dd)
if ! date -d "$expire_date" >/dev/null 2>&1; then
    echo "Invalid date format. Please use yyyy/mm/dd."
    exit 1
fi

# Generate the useradd command
# useradd_command="useradd -M -s /bin/vpn.sh -e $expire_date $username"
useradd_command="useradd -M -e $expire_date $username"

# Add the user and set the password
$useradd_command
echo "$username:$password" | chpasswd

# Print information
echo "User '$username' added with limit '$limit' and expire date '$expire_date'."

# Add user, limit, and expire date to the CSV file
echo "$username,$limit,$expire_date" >> user_limits.csv
