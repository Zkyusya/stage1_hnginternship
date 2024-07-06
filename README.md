This repo contains a Bash Script for creating and managing Linux users. 
Additionally, it reads a text file containing usernames and group names, then; 

**•User and Group Creation:** Ensures each user has a personal group with the same name handling creation of multiple groups and adds users to these groups.

**•Home Directory Setup:** Creates home directories with appropriate permissions and ownership

**•Password Generation and Security:** Generates random passwords and stored securely. Only the file owner can read the password file.

**• Logging:** Logs All actions in `var/log/user_management.log` file for auditing purposes

 **Password and User Management:** Stores all the users and their generated passwords in `/var/secure/user_passwords.txt` file


