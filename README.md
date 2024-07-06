This repo contains a Bash Script for creating and managing Linux users. 
Additionally, it reads a text file containing usernames and group names, creates the users and groups, sets up home directories, generates random passwords, and logs all actions. The generated passwords are securely stored in a protected file.

Key Points 
•User and Group Creation:The script ensures each user has a personal group with the same name. It handles the creation of multiple groups and adds users to these groups.

•Home Directory Setup: Home directories are created with appropriate permissions and ownership

•Password Generation and Security: Random passwords are generated and stored securely. Only the file owner can read the password file.

• Logging: All actions are logged in `var/log/user_management.log` file for auditing purposes
 Stores all the users and their generated passwords in `/var/secure/user_passwords.txt` file


