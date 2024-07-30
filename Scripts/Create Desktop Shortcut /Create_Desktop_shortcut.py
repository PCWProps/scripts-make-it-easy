# This script will create a desktop short cut for the user to launch the app
# The app will be authenticated with the secret store if required
# The app will be launched with the secret store credentials if required

# Fill in the values below to create the desktop short cut
app_name = "MyApp"
app_secret_path = "/usr/share/secrets/myapp.secret"
requires_auth = True  # Set to True if the app requires authentication

#os discovery
import os 
import shutil

def find_app_path(app_name):
    app_path = shutil.which(app_name)
    if app_path:
        return app_path
    else:
        raise FileNotFoundError(f"Executable for {app_name} not found.")

def find_app_icon(app_name):
    icon_dirs = [
        "/usr/share/icons/hicolor/48x48/apps/",
        "/usr/share/pixmaps/",
        "/usr/share/icons/"
    ]
    for icon_dir in icon_dirs:
        icon_path = os.path.join(icon_dir, f"{app_name}.png")
        if os.path.exists(icon_path):
            return icon_path
    raise FileNotFoundError(f"Icon for {app_name} not found.")

def create_desktop_shortcut(app_name, app_secret_path, requires_auth):
    app_path = find_app_path(app_name)
    app_icon = find_app_icon(app_name)

    # Create a desktop shortcut file
    desktop_path = os.path.expanduser("~/Desktop")
    shortcut_file = os.path.join(desktop_path, f"{app_name}.desktop")

    # Write the shortcut file contents
    with open(shortcut_file, "w") as f:
        f.write("[Desktop Entry]\n")
        f.write(f"Name={app_name}\n")
        if requires_auth:
            f.write(f"Exec={app_path} --secret=$(cat {app_secret_path})\n")
        else:
            f.write(f"Exec={app_path}\n")
        f.write(f"Icon={app_icon}\n")
        f.write("Type=Application\n")

    print(f"Desktop shortcut created at: {shortcut_file}")

# Example usage
app_name = "myapp"
app_secret_path = "/usr/share/secrets/myapp.secret"
requires_auth = True  # Set to True if the app requires authentication

create_desktop_shortcut(app_name, app_secret_path, requires_auth)