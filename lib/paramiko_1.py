import os
import time
import paramiko
from scp import SCPClient, SCPException

# Define your EC2 details
key_path = 'B:/Fiverr Projects/Retscan_Files/Retscan-key.pem'
hostname = '35.178.199.186'  # Your EC2 public IP
username = 'Administrator'  # Adjust based on your AMI
local_file_path = 'B:/Fiverr Projects/RetScan_App.zip'
remote_file_path = '/C:/Users/Administrator/RetScan_App.zip'

# Function to show progress of file transfer
def progress(filename, size, sent):
    percentage = (sent / size) * 100
    print(f"\r{filename}: {sent}/{size} bytes transferred ({percentage:.2f}%)", end='')

# Function to upload file with retry mechanism
def upload_with_retry(retries=5):
    for attempt in range(retries):
        try:
            # Create an SSH client
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

            # Connect to the instance
            ssh.connect(hostname, username=username, key_filename=key_path, timeout=300)

            # Use SCP to copy the file with progress
            with SCPClient(ssh.get_transport(), progress=progress) as scp:
                scp.put(local_file_path, remote_file_path)

            print("\nFile uploaded successfully!")
            break  # Exit the loop if upload is successful

        except (paramiko.ssh_exception.SSHException, SCPException) as e:
            print(f"\nAttempt {attempt + 1} failed: {e}")
            if attempt < retries - 1:
                print("Retrying...")
                time.sleep(10)  # Wait before retrying
            else:
                print("All attempts failed. File upload was not successful.")
        finally:
            ssh.close()

# Call the upload function
upload_with_retry()
