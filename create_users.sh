#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Check if the input file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <user_list_file>"
    exit 1
fi

USER_LIST_FILE=$1

# Log file and password file paths
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.csv"

# Ensure secure directory exists and is protected
mkdir -p /var/secure
chmod 700 /var/secure

# Create or clear log and password files
> $LOG_FILE
> $PASSWORD_FILE

# Function to generate random password
generate_password() {
    tr -dc A-Za-z0-9 </dev/urandom | head -c 12
}

# Read the user list file and process each line
while IFS=';' read -r username groups; do
    username=$(echo "$username" | xargs) # Trim whitespace

    # Create the user and personal group
    if id "$username" &>/dev/null; then
        echo "User $username already exists" | tee -a $LOG_FILE
    else
        useradd -m -s /bin/bash "$username" -g "$username"
        echo "Created user $username and personal group $username" | tee -a $LOG_FILE
    fi

    # Set up home directory
    HOME_DIR="/home/$username"
    chmod 755 "$HOME_DIR"
    chown "$username:$username" "$HOME_DIR"
    echo "Set up home directory for $username" | tee -a $LOG_FILE

    # Create and add user to additional groups
    IFS=',' read -ra ADDITIONAL_GROUPS <<< "$groups"
    for group in "${ADDITIONAL_GROUPS[@]}"; do
        group=$(echo "$group" | xargs) # Trim whitespace
        if ! getent group "$group" > /dev/null 2>&1; then
            groupadd "$group"
            echo "Created group $group" | tee -a $LOG_FILE
        fi
        usermod -aG "$group" "$username"
        echo "Added $username to group $group" | tee -a $LOG_FILE
    done

    # Generate and set password
    PASSWORD=$(generate_password)
    echo "$username:$PASSWORD" | chpasswd
    echo "$username,$PASSWORD" >> $PASSWORD_FILE
    echo "Set password for $username" | tee -a $LOG_FILE

done < "$USER_LIST_FILE"

# Secure the password file
chmod 600 $PASSWORD_FILE
echo "Password file stored at $PASSWORD_FILE with secure permissions" | tee -a $LOG_FILE

echo "User creation process completed" | tee -a $LOG_FILE

