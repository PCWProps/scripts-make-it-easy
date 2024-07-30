#script to change username
Values:
new_username="CaptainFrank"
old_username="CaptianFrank"

# Change username
sudo usermod -l $new_username $old_username

# Rename the Home Directory
sudo mv /home/$old_username /home/$new_username

# Update the Home Directory Path
sudo usermod -d /home/$new_username $new_username

# Update File Ownership
sudo chown -R $new_username:$new_username /home/$new_username

# Update group Name
sudo groupmod -n $new_username $old_username

# Reboot to apply changes

sudo reboot
//end of script