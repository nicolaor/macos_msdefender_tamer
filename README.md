# Microsoft Defender Tamer for macOS

This guide describes how to configure a macOS system to automatically reduce the resource consumption of Microsoft Defender processes when running on battery power.
On a macbook pro 16" M4 (2024) Battery life increased 4x (from 2-3 hours to 8-12 hours)

## 🔧 Features

- Detects when the system is running on battery.
- Reduces priority (`nice`) and places selected Defender processes into background mode.
- Automatically reverts settings when plugged into AC power.
- Runs periodically every 3 minutes using a launch agent.

---

## 📁 1. Place the Script

1. Create a `Scripts` directory in your home folder if it doesn’t exist:
   ```bash
   mkdir -p ~/Scripts
   ```

2. Save the following script as `defender_tamer.sh` inside the `~/Scripts` directory:
   ```bash
   chmod +x ~/Scripts/defender_tamer.sh
   ```

---

## ⚙️ 2. Configure Launch Agent

1. Create a LaunchAgent at:
   ```bash
   mkdir -p ~/Library/LaunchAgents
   ```

2. Save the following content as `com.nicolaor.defender.tamer.plist` in `~/Library/LaunchAgents/`:

   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>Label</key>
       <string>com.nicolaor.defender.tamer</string>
       <key>ProgramArguments</key>
       <array>
           <string>$HOME/Scripts/defender_tamer.sh</string>
       </array>
       <key>StartInterval</key>
       <integer>180</integer> <!-- Run every 3 minutes -->
       <key>RunAtLoad</key>
       <true/>
       <key>StandardOutPath</key>
       <string>/tmp/defender_tamer.log</string>
       <key>StandardErrorPath</key>
       <string>/tmp/defender_tamer.err</string>
   </dict>
   </plist>
   ```

3. Load the LaunchAgent:
   ```bash
   launchctl load ~/Library/LaunchAgents/com.nicolaor.defender.tamer.plist
   ```

---

## 🔐 3. Configure `sudo` Permissions

To avoid password prompts on every run, add the following line to your `sudoers` file using `sudo visudo`:

```bash
sudo visudo
```

Append:
```bash
your-username ALL=(ALL) NOPASSWD: \
/usr/bin/pmset -a lowpowermode *, \
/usr/bin/renice * -p *, \
/usr/bin/taskpolicy -b -p *, \
/usr/bin/taskpolicy -p *
```

Replace `your-username` with your actual macOS username.

---

## ✅ Done!

The Defender Tamer script will now monitor your power source and automatically optimize Defender processes accordingly.