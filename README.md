This is my Level 1 Project as a HNG Intern

**Automating Linux User Management with a Bash Script**

Managing user accounts in a Linux environment can be a tedious and error-prone process, especially when dealing with a large number of users. As a DevOps engineer, ensuring that each user is created with the correct permissions, groups, and secure credentials is crucial for maintaining system security and efficiency.
As part of HNG Internship, was assigned a real-world scenario of writing a Bash script designed to automate the process of user and group creation, home directory setup, and password management. This script not only simplifies the user management process but also ensures consistency and security across the system.

**Bash Script: create_users.sh**

In this technical article, we will walk through the process of creating and managing Linux users using a bash script. This script, create_users.sh, reads a text file containing usernames and group names, creates the users and groups, sets up home directories, generates random passwords, and logs all actions. The generated passwords are securely stored in a protected file.

**1. Check Root Permissions: Ensures the script is run with root privileges.**
```
bash
Copy code
#!/bin/bash
_# Check if the script is run as root_
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi
```
**2. Validate Input File: Checks if the input file containing user details is provided**
``` _# Check if the input file is provided_
if [ -z "$1" ]; then
    echo "Usage: $0 <user_list_file>"
    exit 1
fi
USER_LIST_FILE=$1
```
**3. Initialize Log and Password Files: Prepares the log file (/var/log/user_management.log) and the password file (/var/secure/user_passwords.csv).**
```_# Log file and password file paths_
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.csv"

_# Ensure secure directory exists and is protected_
mkdir -p /var/secure
chmod 700 /var/secure

_# Create or clear log and password files_
> $LOG_FILE
> $PASSWORD_FILE
```

**4. Generate Random Passwords: Defines a function to generate random passwords.**
``` _# Function to generate random password_
generate_password() {
    tr -dc A-Za-z0-9 </dev/urandom | head -c 12
}

```
**5. Process User List: Reads the input file line by line, processes each username and associated groups**
``` _# Read the user list file and process each line_
while IFS=';' read -r username groups; do
    username=$(echo "$username" | xargs) # Trim whitespace

    ```
**6. Create Users and Groups: Creates users, personal groups, and additional groups as specified.**
 ``` _ # Create the user and personal group_
    if id "$username" &>/dev/null; then
        echo "User $username already exists" | tee -a $LOG_FILE
    else
        useradd -m -s /bin/bash "$username" -g "$username"
        echo "Created user $username and personal group $username" | tee -a $LOG_FILE
    fi
```
    
**7. Set Home Directory: Sets up the home directory with appropriate permissions and ownership.**
``` _# Set up home directory_
    HOME_DIR="/home/$username"
    chmod 755 "$HOME_DIR"
    chown "$username:$username" "$HOME_DIR"
    echo "Set up home directory for $username" | tee -a $LOG_FILE
```
    
**8. Assign Groups and Passwords: Adds users to additional groups and sets random passwords.**
``` _  # Create and add user to additional groups_
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

_    # Generate and set password_
    PASSWORD=$(generate_password)
    echo "$username:$PASSWORD" | chpasswd
    echo "$username,$PASSWORD" >> $PASSWORD_FILE
    echo "Set password for $username" | tee -a $LOG_FILE

done < "$USER_LIST_FILE"
```

**9. Log Actions and Secure Password File: Logs all actions and ensures the password file is securely stored.**
``` _# Secure the password file_
chmod 600 $PASSWORD_FILE
echo "Password file stored at $PASSWORD_FILE with secure permissions" | tee -a $LOG_FILE

echo "User creation process completed" | tee -a $LOG_FILE
```

**Key Points**

•User and Group Creation:The script ensures each user has a personal group with the same name. It handles the creation of multiple groups and adds users to these groups.

•Home Directory Setup: Home directories are created with appropriate permissions and ownership

•Password Generation and Security: Random passwords are generated and stored securely. Only the file owner can read the password file.

• Logging: All actions are logged for auditing purposes

This script simplifies the task of user management in a Linux environment, ensuring consistency and security.

Learn more about the HNG Internship and opportunities to grow as a developer:

**• HNG Internship**

**• HNG Premium**
