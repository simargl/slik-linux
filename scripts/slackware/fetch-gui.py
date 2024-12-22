#!/usr/bin/env python3

import os
import requests
import gi
import subprocess
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, GdkPixbuf

class PackageDownloader(Gtk.Window):
    def __init__(self):
        super().__init__(title="Fetch GUI Package Manager")
        self.set_border_width(10)
        self.set_default_size(1100, 800)
        self.set_icon_name("package-x-generic")

        # Create a vertical box layout for the main window
        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        self.add(vbox)

        # Create a search entry
        self.search_entry = Gtk.Entry()
        self.search_entry.set_placeholder_text("Search packages...")
        self.search_entry.connect("changed", self.on_search_changed)
        vbox.pack_start(self.search_entry, False, False, 0)

        # Create a TreeView for displaying packages
        self.package_list_store = Gtk.ListStore(str, str, str, bool)  # URL, Package Name, Description, Installed
        self.filtered_package_list_store = self.package_list_store.filter_new()
        self.filtered_package_list_store.set_visible_func(self.filter_visible_func)

        self.treeview = Gtk.TreeView(model=self.filtered_package_list_store)

        # Add a column with a green square for installed packages
        renderer_pixbuf = Gtk.CellRendererPixbuf()
        column_status = Gtk.TreeViewColumn("Status", renderer_pixbuf)
        column_status.set_cell_data_func(renderer_pixbuf, self.render_status_icon)
        self.treeview.append_column(column_status)

        # Add columns for package name and description
        for i, column_title in enumerate(["Package Name", "Description"]):
            renderer = Gtk.CellRendererText()
            column = Gtk.TreeViewColumn(column_title, renderer, text=i + 1)  # Skip URL (index 0)
            self.treeview.append_column(column)

        # Enable multi-selection mode
        self.treeview.get_selection().set_mode(Gtk.SelectionMode.MULTIPLE)

        # Add TreeView to a ScrolledWindow
        scrolled_window = Gtk.ScrolledWindow()
        scrolled_window.set_vexpand(True)
        scrolled_window.add(self.treeview)
        vbox.pack_start(scrolled_window, True, True, 0)

        # Create a horizontal box to place buttons beside each other
        button_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        vbox.pack_start(button_box, False, False, 0)

        # Add a download button
        self.download_button = Gtk.Button(label="Download Selected")
        self.download_button.connect("clicked", self.on_download_button_clicked)
        button_box.pack_start(self.download_button, True, True, 0)

        # Add an install button
        self.install_button = Gtk.Button(label="Install Selected")
        self.install_button.connect("clicked", self.on_install_button_clicked)
        button_box.pack_start(self.install_button, True, True, 0)

        # Add a remove button
        self.remove_button = Gtk.Button(label="Remove Selected")
        self.remove_button.connect("clicked", self.on_remove_button_clicked)
        button_box.pack_start(self.remove_button, True, True, 0)

        # Add a progress bar
        self.progress_bar = Gtk.ProgressBar()
        self.progress_bar.set_show_text(True)
        vbox.pack_start(self.progress_bar, False, False, 0)

        # Load package data from the database
        self.load_packages()

    def filter_visible_func(self, model, iter, data):
        """Filter function for the visible rows in the filtered model."""
        search_text = self.search_entry.get_text().lower()
        package_name = model[iter][1].lower()
        description = model[iter][2].lower()
        return search_text in package_name or search_text in description

    def on_search_changed(self, entry):
        """Callback for when the search text changes."""
        self.filtered_package_list_store.refilter()

    def render_status_icon(self, column, cell_renderer, model, iter, data=None):
        """Render a green square icon for installed packages."""
        installed = model[iter][3]  # Column index 3 for 'installed'
        if installed:
            cell_renderer.set_property("pixbuf", self.get_pixbuf_from_color("green"))
        else:
            cell_renderer.set_property("pixbuf", self.get_pixbuf_from_color("white"))

    def get_pixbuf_from_color(self, color_name):
        """Create a 16x16 square pixbuf with the given color."""
        width, height = 16, 16
        color_map = {
            "green": (0, 255, 0),  # Green color for installed
            "white": (255, 255, 255)  # White color for not installed
        }
        r, g, b = color_map.get(color_name, (255, 255, 255))

        # Create a writable array for pixel data
        data = bytearray(width * height * 3)  # 3 bytes per pixel (RGB)
        for y in range(height):
            for x in range(width):
                offset = (y * width + x) * 3
                data[offset:offset + 3] = (r, g, b)

        # Create a pixbuf from the pixel data
        pixbuf = GdkPixbuf.Pixbuf.new_from_data(
            bytes(data), GdkPixbuf.Colorspace.RGB, False, 8, width, height, width * 3
        )
        return pixbuf

    def get_package_name_from_filename(self, filename):
        """Extract the package name from the filename (before the last three dashes)."""
        parts = filename.split("-")
        package_name = "-".join(parts[:-3])  # Join all parts except the last three
        return package_name

    def load_packages(self):
        """Load package data from /var/lib/slackware/packages.db into the ListStore."""
        db_path = "/var/lib/slackware/packages.db"
        if not os.path.exists(db_path):
            print(f"Error: {db_path} does not exist.")
            return

        with open(db_path, "r") as db_file:
            for line in db_file:
                line = line.strip()
                if "|" in line:
                    url, description = line.split("|", 1)
                    package_name = url.split("/")[-1]  # Extract the package name from the URL
                    package_base_name = self.get_package_name_from_filename(package_name)

                    # Check if the package is installed
                    install_path = f"/var/lib/slackware/installed/{package_base_name}"
                    installed = os.path.isdir(install_path)   

                    # Append to the ListStore
                    self.package_list_store.append([url, package_name, description, installed])

    def show_error_dialog(self, message):
        """Display an error dialog with the given message."""
        dialog = Gtk.MessageDialog(
            transient_for=None,
            flags=0,
            message_type=Gtk.MessageType.ERROR,
            buttons=Gtk.ButtonsType.OK,
            text="Error",
        )
        dialog.format_secondary_text(message)
        dialog.run()
        dialog.destroy()

    def on_download_button_clicked(self, widget):
        """Handle download button clicks."""
        selection = self.treeview.get_selection()
        model, treeiters = selection.get_selected_rows()

        if treeiters:
            # Get the selected packages and download them
            for path in treeiters:
                treeiter = model.get_iter(path)
                url = model[treeiter][0]  # Get the URL from the selected row
                package_name = model[treeiter][1]
                self.download_package(url, package_name)
        else:
            print("No packages selected.")

    def download_package(self, url, package_name):
        """Download the selected package and save it to /var/cache/slackware."""
        download_dir = "/var/cache/slackware"
        
        # Ensure the directory exists
        if not os.path.exists(download_dir):
            print(f"Error: {download_dir} does not exist. Creating it now.")
            try:
                os.makedirs(download_dir)
            except PermissionError:
                print(f"Error: Permission denied to create {download_dir}. Please run as root.")
                return

        try:
            print(f"Downloading {package_name} from {url}...")

            # Set the progress bar text
            self.progress_bar.set_text(f"Downloading {package_name}...")

            # Get the package content
            response = requests.get(url, stream=True)
            response.raise_for_status()  # Raise an exception for HTTP errors

            # Get the filename from the URL (the last part of the URL after '/')
            filename = url.split("/")[-1]
            local_path = os.path.join(download_dir, filename)

            # Download the file in chunks and save it locally
            with open(local_path, "wb") as f:
                total_size = int(response.headers.get('Content-Length', 0))
                downloaded = 0
                self.progress_bar.set_fraction(0)  # Reset the progress bar
                for chunk in response.iter_content(chunk_size=1024):
                    if chunk:
                        f.write(chunk)
                        downloaded += len(chunk)
                        # Update progress bar
                        self.progress_bar.set_fraction(downloaded / total_size)
                        while Gtk.events_pending():
                            Gtk.main_iteration()

            # Update the progress bar text after download completion
            self.progress_bar.set_text(f"Downloaded {package_name} as {filename}.")
            print(f"Downloaded {package_name} as {local_path}.")
        except Exception as e:
            print(f"Error downloading {package_name}: {e}")
            self.progress_bar.set_fraction(0)  # Reset progress bar in case of error
            self.progress_bar.set_text(f"Error downloading {package_name}.")

    def on_install_button_clicked(self, widget):
        """Handle the install button click."""
        selection = self.treeview.get_selection()
        model, treeiters = selection.get_selected_rows()

        if treeiters:
            # List to hold all downloaded packages
            downloaded_files = []

            # For each selected package, download and add it to the install list
            for path in treeiters:
                treeiter = model.get_iter(path)
                package_name = model[treeiter][1]
                package_filename = os.path.join("/var/cache/slackware", package_name)

                # Check if the package is already downloaded
                if not os.path.exists(package_filename):
                    # If not, download it first
                    url = model[treeiter][0]
                    self.download_package(url, package_name)

                # After download (or if already downloaded), add to the install list
                downloaded_files.append(package_filename)

            # Install the packages once they are all downloaded
            if downloaded_files:
                self.install_packages(downloaded_files)
        else:
            print("No packages selected.")

    def install_packages(self, package_filenames):
        """Install multiple packages using fetch it."""
        try:
            # Change directory to /var/cache/slackware
            print("Changing directory to /var/cache/slackware")
            os.chdir("/var/cache/slackware")

            # Show installation progress
            self.progress_bar.set_text(f"Installing packages...")

            # Execute fetch it for each package individually
            for package_filepath in package_filenames:
                # Get the filename from the full path
                package_filename = os.path.basename(package_filepath)
                package_base_name = self.get_package_name_from_filename(package_filename)
                
                install_path = f"/var/lib/slackware/installed/{package_base_name}"
                installed = os.path.isdir(install_path)  
                
                if installed:
                    self.show_error_dialog(f"The package '{package_filename}' is already installed.")
                    return

                print(f"Installing {package_filename}...")

                # Execute the fetch it command separately after changing the directory
                subprocess.run(["fetch", "it", package_filename], check=True)

                # After installation, update the installed status in the model
                self.update_installed_status(package_base_name, True)

            # Update progress bar text after installation is complete
            self.progress_bar.set_text(f"Installation completed.")
            print(f"Installation completed.")
        except subprocess.CalledProcessError as e:
            print(f"Error during installation: {e}")
            self.progress_bar.set_text(f"Error during installation.")
        except Exception as e:
            print(f"Unexpected error: {e}")
            self.progress_bar.set_text(f"Unexpected error.")

    def on_remove_button_clicked(self, widget):
        """Handle the remove button click."""
        selection = self.treeview.get_selection()
        model, treeiters = selection.get_selected_rows()

        if treeiters:
            for path in treeiters:
                treeiter = model.get_iter(path)
                package_name = model[treeiter][1]
                package_base_name = self.get_package_name_from_filename(package_name)

                install_path = f"/var/lib/slackware/installed/{package_base_name}"
                installed = os.path.isdir(install_path)  
                
                if installed == False:
                    self.show_error_dialog(f"The package '{package_name}' is not installed, so it cannot be removed.")
                    return

                print(f"Removing {package_name}...")

                # Run the "fetch rm pkgname" command to remove the package
                subprocess.run(["fetch", "rm", package_base_name], check=True)

                # Update the installed status in the model
                self.update_installed_status(package_base_name, False)

                # Update the progress bar text
                self.progress_bar.set_text(f"Removed {package_name}.")
        else:
            print("No packages selected.")
            self.progress_bar.set_text("No packages selected for removal.")

    def update_installed_status(self, package_base_name, installed):
        """Update the installed status of the package in the ListStore."""
        for row in self.package_list_store:
            base_name_in_store = self.get_package_name_from_filename(row[1])  # Get base name from package filename in ListStore
            if base_name_in_store == package_base_name:  # Match the base package name
                row[3] = installed  # Update the 'installed' status
                break  # Stop once the correct package is updated

        # Refresh the TreeView to reflect the changes in the icon column
        self.treeview.queue_draw()

# Create the GTK application window and run the application
window = PackageDownloader()
window.connect("destroy", Gtk.main_quit)
window.show_all()
Gtk.main()
