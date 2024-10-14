
## MacOS Rsync iCloud to Linux

This repository contains two useful scripts for synchronizing iCloud files from macOS to a Linux server using rsync and fixing filenames that are incompatible with the Linux EXT4 filesystem. Below are the descriptions and setup instructions for each script.
 

**iCloud Sync Script**
 

This script automates the synchronization of iCloud files from macOS to a Linux server via rsync over SSH. It monitors your local iCloud folder and automatically syncs changes to the remote server in real-time.
 

**Key Features:**
 
    - Automatic Sync: Continuously watches for changes in your iCloud folder and syncs them to the server.
    - Customizable Exclusions: Skips unnecessary files like .DS_Store and temporary system files.
    - Real-Time Monitoring: Uses fswatch to monitor the local folder for updates.
    - SSH Authentication: Synchronizes files over SSH using a password stored in the script.
    - Logging Support: Optionally logs sync operations to a file for easy tracking.

  
**Setup Instructions:**
 

1. **Edit the Script Variables**:

Open the icloud_sync.sh script and update the following values:

    - USER: Your macOS username.
    - SRC: The iCloud folder path to be synced.
    - SSH_USER: The username of your remote Linux server.
    - SSH_PASSWORD: The password for the remote server.
    - SSH_HOST: The IP address or hostname of your server.
    - DEST: The destination directory on the remote server.

2. **Install Dependencies**:

You’ll need to have rsync and fswatch installed on your macOS. Install them using Homebrew:

    brew install rsync fswatch

3. **Make the Script Executable**:

Grant execute permissions to the script by running:

    chmod +x /path/to/icloud_sync.sh
    
4. **Run the Script**:

*To manually start the synchronization, run the following command:*

    ./icloud_sync.sh


<b><b><b>**Automate the Sync with macOS Launchd:**
  

1. **Edit the** .plist **File**:

•  Modify the com.yourusername.icloudsync.plist file to reflect your correct username and path to the icloud_sync.sh script.

2. **Move the** .plist **File**:

Copy the .plist file to the macOS LaunchAgents folder:

    cp com.yourusername.icloudsync.plist /Library/LaunchDaemons

3. **Activate the Sync**:

Load the plist file with launchctl to start syncing on login:

    sudo launchctl bootstrap system /Library/LaunchDaemons/com.yourusername.icloudsync.plist

To unload the plist file :

    sudo launchctl bootout system /Library/LaunchDaemons/com.yourusername.icloudsync.plist



## Linux-Incompatible Filename Cleaner
  
This script searches a directory for files with names that contain characters incompatible with the Linux EXT4 file system (e.g., :, /, *, ?, etc.). It renames the files by replacing invalid characters and creates backup copies of the original files.
 

**Key Features:**
 

•  **Incompatible Character Detection**: Detects and replaces characters that aren’t allowed in Linux filenames.
•  **Backup System**: Backs up the original files before renaming them.
•  **Customizable Search and Backup Locations**: Specify directories for scanning and backups.
•  **Automated Renaming**: Automatically replaces invalid characters with dashes (-) and renames the files.
 

**Setup Instructions:**
  

1. **Edit the Script Variables**:

Open the search.sh script and modify the following variables:
•  SEARCH_DIR: The directory where the script will search for files with invalid filenames.
•  BACKUP_DIR: A directory where backup copies of the original files will be stored.

2. **Make the Script Executable**:

Make the script executable by running:

    chmod +x /path/to/search.sh

3. **Run the Script**:

Execute the script to scan for invalid filenames and automatically rename them:

    ./search.sh

**Example Use Case:**
 

If you are syncing files from macOS to a Linux server, you may encounter filenames that contain characters not supported by the Linux EXT4 filesystem. This script helps by cleaning up those filenames, ensuring they are valid on both macOS and Linux systems.
 

**Conclusion**
 

These two scripts are essential for automating the synchronization of iCloud files between macOS and Linux, as well as ensuring compatibility with Linux file naming conventions. Feel free to customize them according to your needs!




**Troubleshooting Permissions Issues**

If the script doesn’t work due to permission issues, you can resolve it by allowing access to the required directories:
  
1. **Open Finder** and go to the **“Go”** menu.
2.  Select **“Go to Folder…”**.
3.  In the search box that appears, enter /opt and hit **Enter**.
4.  Once the /opt folder opens, drag it into the macOS **System Preferences**.
5.  In **System Preferences**, navigate to **Security & Privacy** > **Privacy** > **Full Disk Access**.
6.  Under **Full Disk Access**, add /opt to the list of directories allowed access to all user files.
 

This will grant the script permission to access the necessary directories and files on your system.



## Setting Up Automatic SSH Login from macOS to Linux

To enable passwordless SSH login from macOS to a Linux machine, follow these steps:

1. Generate an SSH key on your macOS machine:
   ```bash
   ssh-keygen -t ed25519
   ```

2. Copy the SSH key to your Linux machine:
   ```bash
   ssh-copy-id user@host
   ```

3. Add the key to the macOS keychain:
   ```bash
   ssh-add --apple-use-keychain ~/.ssh/id_ed25519
   ```

4. Configure SSH to use the keychain automatically. Open the SSH configuration file:
   ```bash
   nano ~/.ssh/config
   ```

   Add the following lines to the file:
   ```plaintext
   Host *
     UseKeychain yes
     AddKeysToAgent yes
     IdentityFile ~/.ssh/id_ed25519
   ```

---

### Install `rsync` on Linux

Make sure `rsync` is installed on the Linux machine, as the script depends on it. You can install it using:

```bash
sudo nala install rsync (or sudo apt install rsync)
```
