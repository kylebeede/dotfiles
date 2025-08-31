#!/usr/bin/env python3
"""
GitHub Enterprise Notification Monitor for macOS Menu Bar
"""

import rumps
import requests
import webbrowser
import os
import sys
from threading import Timer
import urllib3
import subprocess
import json

# Disable SSL warnings
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

class GitHubNotificationApp(rumps.App):
    def __init__(self):
        super(GitHubNotificationApp, self).__init__("GH", quit_button=None)
        
        # Configuration
        self.api_url = "https://api.git.faithlife.dev/notifications"
        self.web_url = "https://git.faithlife.dev/notifications"
        self.refresh_interval = 60  # seconds

        def get_token_from_keychain():
            """Get GitHub token from macOS Keychain"""
            try:
                result = subprocess.run(
                    ['security', 'find-generic-password', 
                     '-s', 'github-enterprise-notifier', 
                     '-w'],
                    capture_output=True,
                    text=True,
                    check=True
                )
                return result.stdout.strip()
            except subprocess.CalledProcessError:
                return None

        # Get auth token
        self.token = os.environ.get('GITHUB_ENTERPRISE_TOKEN') or get_token_from_keychain()
        if not self.token:
            # First time setup - prompt for token and save to keychain
            from getpass import getpass
            token = getpass("Enter GitHub Enterprise Token: ")
            if token:
                subprocess.run([
                    'security', 'add-generic-password',
                    '-s', 'github-enterprise-notifier',
                    '-a', os.environ.get('USER'),
                    '-w', token,
                    '-U'  # Update if exists
                ])
                self.token = token
            else:
                rumps.alert("Configuration Error", "No token provided")
                rumps.quit_application()        

        script_dir = os.path.dirname(os.path.abspath(__file__))
        
        self.icon_no_notifications = os.path.join(script_dir, "github-mark.png")
        self.icon_has_notifications = os.path.join(script_dir, "github-mark-white.png")
        
        if not os.path.exists(self.icon_no_notifications):
            rumps.alert("Error", f"Icon not found: github-mark.png\nPlease place it in: {script_dir}")
            rumps.quit_application()
        if not os.path.exists(self.icon_has_notifications):
            rumps.alert("Error", f"Icon not found: github-mark-white.png\nPlease place it in: {script_dir}")
            rumps.quit_application()
        
        self.icon = self.icon_no_notifications
        
        # Add menu items
        self.menu = [
            rumps.MenuItem("Open Notifications", callback=self.open_notifications),
            rumps.MenuItem("Refresh Now", callback=self.refresh_notifications),
            None,  # Separator
            rumps.MenuItem("Quit", callback=self.quit_app)
        ]
        
        self.check_notifications()
    
    def check_notifications(self, _=None):
        """Check for unread notifications"""
        try:
            headers = {
                'Authorization': f'token {self.token}',
                'Accept': 'application/vnd.github.v3+json',
                'User-Agent': 'GitHub-Notifier-App'
            }
            
            # Disable SSL verification for enterprise GitHub with self-signed certs
            response = requests.get(
                self.api_url,
                headers=headers,
                timeout=10,
                verify=False
            )
            
            if response.status_code == 200:
                notifications = response.json()
                has_unread = any(not n.get('unread', False) == False for n in notifications)
                if has_unread and len(notifications) > 0:
                    self.icon = self.icon_has_notifications
                else:
                    self.icon = self.icon_no_notifications
            elif response.status_code == 401:
                print(f"Authentication error: {response.status_code}")
                self.icon = self.icon_no_notifications
            else:
                print(f"API error: {response.status_code}")
                print(f"Response: {response.text}")
                self.icon = self.icon_no_notifications
                
        except requests.RequestException as e:
            print(f"Network error: {e}")
            self.icon = self.icon_no_notifications
        except Exception as e:
            print(f"Unexpected error: {e}")
            self.icon = self.icon_no_notifications
        
        # Schedule next check
        self.timer = Timer(self.refresh_interval, self.check_notifications)
        self.timer.daemon = True
        self.timer.start()
    
    def open_notifications(self, _):
        """Open GitHub notifications in browser"""
        webbrowser.open(self.web_url)
    
    def refresh_notifications(self, _):
        """Manually refresh notifications"""
        if hasattr(self, 'timer'):
            self.timer.cancel()
        self.check_notifications()
    
    def quit_app(self, _):
        """Quit the application"""
        if hasattr(self, 'timer'):
            self.timer.cancel()
        rumps.quit_application()

if __name__ == "__main__":
    app = GitHubNotificationApp()
    app.run()
