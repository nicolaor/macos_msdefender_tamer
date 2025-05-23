# macos_msdefender_tamer


# 🛡️ Microsoft Defender Tamer for macOS Battery Optimization

This guide helps you reduce the resource impact of Microsoft Defender on your MacBook while on battery power by lowering the priority of its background processes.

---

## 📁 1. Install the Script

1. Create a directory to store your scripts (if not already present):

   ```bash
   mkdir -p ~/Scripts
   ```

2. Copy the `defender_tamer.sh` script into `~/Scripts`.

3. Make it executable:

   ```bash
   chmod +x ~/Scripts/defender_tamer.sh
   ```

---

## ⚙️ 2. Create a Launch Agent

1. Save the following contents to:  
   `/Library/LaunchDaemons/com.mondaycoffee.defender.tamer.plist`

   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>Label</key>
       <string>com.mondaycoffee.defender.tamer</string>

       <key>ProgramArguments</key>
       <array>
           <string>/Users/rene.nicolao/Scripts/defender_tamer.sh</string>
       </array>

       <key>StartInterval</key>
       <integer>180</integer> <!-- Runs every 3 minutes -->

       <key>RunAtLoad</key>
       <true/>

       <key>StandardOutPath</key>
       <string>/tmp/defender_tamer.log</string>

       <key>StandardErrorPath</key>
       <string>/tmp/defender_tamer.err</string>
   </dict>
   </plist>
   ```

2. Make the `.plist` file readable and executable:

   ```bash
   sudo chmod 644 /Library/LaunchDaemons/com.mondaycoffee.defender.tamer.plist
   ```

3. Load the Launch Daemon:

   ```bash
   sudo launchctl load /Library/LaunchDaemons/com.mondaycoffee.defender.tamer.plist
   ```

---

## 🔐 3. Configure Sudo Permissions (No Password Prompt)

1. Open the sudoers file safely:

   ```bash
   sudo visudo
   ```

2. Add the following line at the end (replace `rene.nicolao` with your username):

   ```bash
   rene.nicolao ALL=(ALL) NOPASSWD: \
   /usr/bin/pmset -a lowpowermode *, \
   /usr/bin/renice * -p *, \
   /usr/bin/taskpolicy -b -p *, \
   /usr/bin/taskpolicy -p *
   ```

---

## 🚀 4. Done!

The script will now run every 3 minutes. When on battery power, it will:

- Lower the priority (`nice +20`) of various Defender-related processes
- Put them in background mode (via `taskpolicy -b`) where supported

When plugged into AC, their original priority and scheduling will be restored.

---

## 🔍 Logs

You can inspect logs in:

```bash
cat /tmp/defender_tamer.log
cat /tmp/defender_tamer.err
```

---

## 🧪 Tested With

- macOS 14+ (Sonoma)
- Microsoft Defender for Endpoint
- Apple Silicon and Intel Macs

