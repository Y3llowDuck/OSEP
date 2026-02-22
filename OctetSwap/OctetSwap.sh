#!/bin/bash
# Fix /etc/hosts after Offsec lab reset
# Only modifies IPs starting with 172.x or 192.x

echo "========================================="
echo "Current OSEP lab IPs (172.x and 192.x):"
echo "========================================="
grep -E '^(172|192)\.' /etc/hosts

echo ""
read -p "Enter the OLD octet to replace (e.g., 223): " OLD_OCTET

# Show what will be changed (only 172.x and 192.x)
echo ""
echo "========================================="
echo "Lines that will be modified:"
echo "========================================="
grep -E "^(172|192)\.[0-9]+\.${OLD_OCTET}\." /etc/hosts

if [ -z "$(grep -E "^(172|192)\.[0-9]+\.${OLD_OCTET}\." /etc/hosts)" ]; then
    echo "No matching IPs found starting with 172.x.${OLD_OCTET}.x or 192.x.${OLD_OCTET}.x"
    exit 1
fi

# Confirm the old octet
echo ""
read -p "Are these the correct lines to modify? (y/n): " CONFIRM_OLD
if [ "$CONFIRM_OLD" != "y" ]; then
    echo "Aborted. No changes made."
    exit 0
fi

echo ""
read -p "Enter the NEW octet (e.g., 108): " NEW_OCTET

# Show preview of changes
echo ""
echo "========================================="
echo "Preview of changes:"
echo "========================================="
echo "BEFORE → AFTER"
grep -E "^(172|192)\.[0-9]+\.${OLD_OCTET}\." /etc/hosts | while read line; do
    new_line=$(echo "$line" | sed -E "s/^(172|192)\.([0-9]+)\.${OLD_OCTET}\./\1.\2.${NEW_OCTET}./")
    echo "$line"
    echo "  → $new_line"
    echo ""
done

# Final confirmation
read -p "Proceed with these changes? (y/n): " CONFIRM_FINAL
if [ "$CONFIRM_FINAL" != "y" ]; then
    echo "Aborted. No changes made."
    exit 0
fi

# Backup
cp /etc/hosts /etc/hosts.bak

# Replace ONLY in lines starting with 172.x or 192.x
sed -i -E "s/^(172|192)\.([0-9]+)\.${OLD_OCTET}\./\1.\2.${NEW_OCTET}./g" /etc/hosts

echo ""
echo "========================================="
echo "✓ Success!"
echo "========================================="
echo "[$(date)] Updated /etc/hosts: ${OLD_OCTET} → ${NEW_OCTET}"
echo "Backup saved to /etc/hosts.bak"
echo ""
echo "Verification - OSEP lab IPs:"
grep -E '^(172|192)\.' /etc/hosts
echo ""
echo "Protected IPs (unchanged):"
grep -E '^(127|10|::1|ff02)' /etc/hosts
