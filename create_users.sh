#!/bin/bash



# Check if the script is run as root

if [ "$(id -u)" -ne 0 ]; then

    echo "This script must be run with sudo or as root." >&2

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



# Create or clear log and password files with root privileges

mkdir -p /var/log

mkdir -p /var/secure

touch $LOG_FILE

chmod 644 $LOG_FILE  # Set permissions for the log file

: > $LOG_FILE  # Clear the log file



touch $PASSWORD_FILE

chmod 600 $PASSWORD_FILE  # Set secure permissions for the password file

: > $PASSWORD_FILE  # Clear the password file



# Function to generate a random password

generate_password() {

    tr -dc A-Za-z0-9 </dev/urandom | head -c 12

}



# Read the user list file and process each line

while IFS=';' read -r username groups; do

    username=$(echo "$username" | xargs) # Trim whitespace



    # Create a personal group for the user

    if ! getent group "$username" &>/dev/null; then

        groupadd "$username"

        echo "Created personal group $username" >> $LOG_FILE

    fi



    # Create the user with a home directory and assign to personal group

    if ! id "$username" &>/dev/null; then

        useradd -m -g "$username" "$username"

        if [ $? -eq 0 ]; then

            echo "Created user $username with personal group $username" >> $LOG_FILE

        else

            echo "Failed to create user $username" >> $LOG_FILE

            continue

        fi

    else

        echo "User $username already exists" >> $LOG_FILE

    fi



    # Assign user to additional groups

    if [ -n "$groups" ]; then

        IFS=',' read -ra group_array <<< "$groups"

        for group in "${group_array[@]}"; do

            group=$(echo "$group" | xargs) # Trim whitespace

            if ! getent group "$group" &>/dev/null; then

                groupadd "$group"

                echo "Created group $group" >> $LOG_FILE

            fi

            usermod -aG "$group" "$username"

            echo "Assigned user $username to group $group" >> $LOG_FILE

        done

    fi



    # Generate and log a password

    PASSWORD=$(generate_password)

    echo "$username,$PASSWORD" >> $PASSWORD_FILE

    echo "Generated password for user $username" >> $LOG_FILE



done < "$USER_LIST_FILE"



echo "User creation process completed" >> $LOG_FILE

