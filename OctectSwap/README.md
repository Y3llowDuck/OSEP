# OctetSwap

> Automated `/etc/hosts` octet replacement tool for OffSec PEN-300 (OSEP) and PEN-200 (OSCP) lab environments.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Kali Linux](https://img.shields.io/badge/Platform-Kali%20Linux-557C94)](https://www.kali.org/)
[![Shell: Bash](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)

When OffSec lab environments reset, IP addresses often change their third octet (e.g., from `172.16.223.x` to `172.16.108.x`). OctetSwap automates this tedious task with safety checks and confirmations.

---

## 🚀 Features

- ✅ **Smart Filtering**: Only modifies IPs starting with `172.x` or `192.x` (OSEP/OSCP lab ranges)
- ✅ **Protection**: Preserves localhost (`127.x`), private IPs (`10.x`), and IPv6 addresses
- ✅ **Safety First**: Multiple confirmation prompts with preview before applying changes
- ✅ **Automatic Backup**: Creates `/etc/hosts.bak` before any modifications
- ✅ **Platform Support**: Works on Kali Linux (x86, x64, ARM, ARM64)

---

## 📋 Prerequisites

- **OS**: Kali Linux (or any Debian-based distribution)
- **Shell**: Bash or Zsh
- **Privileges**: `sudo` access
- **Tools**: `grep`, `sed`, `cp` (pre-installed on Kali)

---

## 📦 Installation

### Method 1: Quick Install (Recommended)

```bash
# Download the script
curl -sL https://raw.githubusercontent.com/Y3llowDuck/OctetSwap/main/Octet-Swap.sh -o /tmp/Octet-Swap.sh

# Install to system
sudo mv /tmp/Octet-Swap.sh /usr/local/bin/Octet-Swap.sh
sudo chmod +x /usr/local/bin/Octet-Swap.sh

# Create alias
echo 'alias OctetSwap="sudo /usr/local/bin/Octet-Swap.sh"' >> ~/.zshrc
source ~/.zshrc
```

### Method 2: Manual Installation

```bash
# Clone the repository
git clone https://github.com/Y3llowDuck/OctetSwap.git
cd OctetSwap

# Install
sudo cp Octet-Swap.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/Octet-Swap.sh

# Create alias (Zsh)
echo 'alias OctetSwap="sudo /usr/local/bin/Octet-Swap.sh"' >> ~/.zshrc
source ~/.zshrc

# OR for Bash users
echo 'alias OctetSwap="sudo /usr/local/bin/Octet-Swap.sh"' >> ~/.bashrc
source ~/.bashrc
```

---

## 🎯 Usage

Simply run the command after your lab resets:

```bash
OctetSwap
```

### Example Session

**Scenario**: Lab IPs changed from `172.16.223.x` to `172.16.108.x`

```bash
$ OctetSwap
=========================================
Current OSEP lab IPs (172.x and 192.x):
=========================================
172.16.223.101	cowmotors-int.com cowmotors-int DC02.cowmotors-int.com DC02
172.16.223.100	cowmotors-int.com cowmotors-int DC01.cowmotors-int.com DC01
192.168.223.201     WEB03.cowmotors-int.com WEB03
172.16.223.221	web01.cowmotors-int.com web01
172.16.223.222	dev02
172.16.223.224	dev03

Enter the OLD octet to replace (e.g., 223): 223

=========================================
Lines that will be modified:
=========================================
172.16.223.101	cowmotors-int.com cowmotors-int DC02.cowmotors-int.com DC02
172.16.223.100	cowmotors-int.com cowmotors-int DC01.cowmotors-int.com DC01
192.168.223.201     WEB03.cowmotors-int.com WEB03
172.16.223.221	web01.cowmotors-int.com web01
172.16.223.222	dev02
172.16.223.224	dev03

Are these the correct lines to modify? (y/n): y

Enter the NEW octet (e.g., 108): 108

=========================================
Preview of changes:
=========================================
BEFORE → AFTER
172.16.223.101	cowmotors-int.com cowmotors-int DC02.cowmotors-int.com DC02
  → 172.16.108.101	cowmotors-int.com cowmotors-int DC02.cowmotors-int.com DC02

172.16.223.100	cowmotors-int.com cowmotors-int DC01.cowmotors-int.com DC01
  → 172.16.108.100	cowmotors-int.com cowmotors-int DC01.cowmotors-int.com DC01

192.168.223.201     WEB03.cowmotors-int.com WEB03
  → 192.168.108.201     WEB03.cowmotors-int.com WEB03

172.16.223.221	web01.cowmotors-int.com web01
  → 172.16.108.221	web01.cowmotors-int.com web01

172.16.223.222	dev02
  → 172.16.108.222	dev02

172.16.223.224	dev03
  → 172.16.108.224	dev03

Proceed with these changes? (y/n): y

=========================================
✓ Success!
=========================================
[Fri Feb 13 14:30:15 CST 2026] Updated /etc/hosts: 223 → 108
Backup saved to /etc/hosts.bak

Verification - OSEP lab IPs:
172.16.108.101	cowmotors-int.com cowmotors-int DC02.cowmotors-int.com DC02
172.16.108.100	cowmotors-int.com cowmotors-int DC01.cowmotors-int.com DC01
192.168.108.201     WEB03.cowmotors-int.com WEB03
172.16.108.221	web01.cowmotors-int.com web01
172.16.108.222	dev02
172.16.108.224	dev03

Protected IPs (unchanged):
127.0.0.1	localhost
127.0.1.1	kali.localdomain	kali
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

---

## 🛡️ Safety Features

### IP Range Filtering
OctetSwap **only** modifies IP addresses starting with:
- `172.x.x.x`
- `192.x.x.x`

### Protected Addresses
The following are **never** modified:
- `127.x.x.x` (localhost)
- `10.x.x.x` (private networks)
- `::1`, `ff02::` (IPv6)

### Example: Protected IPs

**Before running OctetSwap:**
```
172.16.223.101	DC02
127.0.0.1	localhost
10.10.223.50	vpn-gateway
```

**After replacing octet 223 → 108:**
```
172.16.108.101	DC02          ← Changed
127.0.0.1	localhost         ← PROTECTED (unchanged)
10.10.223.50	vpn-gateway   ← PROTECTED (unchanged)
```

---

## 🔧 Advanced Usage

### View Current Configuration

```bash
# View current lab IPs
grep -E '^(172|192)\.' /etc/hosts

# View protected IPs
grep -E '^(127|10|::1|ff02)' /etc/hosts
```

### Restore from Backup

If you need to undo changes:

```bash
sudo cp /etc/hosts.bak /etc/hosts
```

### Manual Execution (Without Alias)

```bash
sudo /usr/local/bin/Octet-Swap.sh
```

---

## ⚠️ Important Notes

### Before Running
1. ✅ **Check OffSec Portal**: Verify the new octet from your lab control panel
2. ✅ **Connect to VPN**: Ensure you're connected to the lab VPN
3. ✅ **Backup Important Data**: Script creates backups, but better safe than sorry

### During Execution
- ⚡ **Read carefully**: Review the preview before confirming
- ⚡ **Verify octets**: Double-check old and new octets before proceeding
- ⚡ **Answer 'y' or 'n'**: Script is case-sensitive for confirmations

### After Running
- 🔍 **Test connectivity**: Ping or scan a host to verify changes
- 🔍 **Check backup**: Backup is at `/etc/hosts.bak`
- 🔍 **Review logs**: Script shows verification output

---

## 🐛 Troubleshooting

### Issue: "Alias not found"

**Solution:**
```bash
# Reload shell configuration
source ~/.zshrc  # for Zsh
# OR
source ~/.bashrc  # for Bash

# Verify alias
alias OctetSwap
```

### Issue: "Permission denied"

**Solution:**
The script requires `sudo` to modify `/etc/hosts`. Ensure your alias includes `sudo`:
```bash
alias OctetSwap="sudo /usr/local/bin/Octet-Swap.sh"
```

### Issue: "No matching IPs found"

**Possible causes:**
1. Wrong old octet entered
2. No lab IPs in `/etc/hosts`
3. Lab IPs don't start with `172.x` or `192.x`

**Solution:**
```bash
# Check current lab IPs
cat /etc/hosts | grep -E '^(172|192)\.'

# Verify the octet you're trying to replace exists
```

### Issue: Different Shell (Bash vs Zsh)

**Check your shell:**
```bash
echo $SHELL
```

**Add alias to correct file:**
- Zsh: `~/.zshrc`
- Bash: `~/.bashrc`

---

## 📚 How It Works

1. **Display**: Shows current OSEP/OSCP lab IPs (`172.x` and `192.x`)
2. **Input**: Prompts for OLD octet (e.g., `223`)
3. **Validate**: Checks if IPs with that octet exist
4. **Confirm**: Shows lines to be modified, asks for confirmation
5. **Input**: Prompts for NEW octet (e.g., `108`)
6. **Preview**: Displays before/after comparison
7. **Confirm**: Final confirmation before applying changes
8. **Backup**: Creates `/etc/hosts.bak`
9. **Apply**: Replaces octet using `sed`
10. **Verify**: Shows updated configuration

---

## 🔐 Security

### Script Location
- **Path**: `/usr/local/bin/Octet-Swap.sh`
- **Owner**: `root:root`
- **Permissions**: `-rwxr-xr-x` (755)

### Why This Is Secure
✅ Root-owned prevents unauthorized modifications  
✅ Stored in system directory, not user home  
✅ Requires `sudo` password for execution  
✅ No network calls or external dependencies  
✅ Creates audit trail via backups  

### Verify Script Integrity
```bash
# Check ownership and permissions
ls -l /usr/local/bin/Octet-Swap.sh

# View script contents
cat /usr/local/bin/Octet-Swap.sh

# Expected owner: root root
# Expected permissions: -rwxr-xr-x
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## ⭐ Acknowledgments

- Created for the OffSec community
- Inspired by the repetitive task of updating `/etc/hosts` after lab resets
- Special thanks to all OSEP/OSCP students who know this pain!

---

## 📧 Support

If you find this tool helpful, please ⭐ star the repository!

For issues, questions, or suggestions:
- Open an [Issue](https://github.com/Y3llowDuck/OctetSwap/issues)
- Submit a [Pull Request](https://github.com/Y3llowDuck/OctetSwap/pulls)

---

## 🔗 Related Projects

Check out my other free pentesting tools:
- [RDP-Automation](https://github.com/Y3llowDuck) - Enable RDP and open required ports after gaining root shell
- [More tools](https://github.com/Y3llowDuck?tab=repositories) - Browse all repositories

---

**Happy Hacking! 🎯**

*Disclaimer: This tool is intended for authorized security testing only. Use responsibly and ethically.*
