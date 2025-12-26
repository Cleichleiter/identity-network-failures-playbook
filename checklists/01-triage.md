\# Triage Checklist (Identity/Network Failures)



\## 1) Confirm the symptom

\- What exactly fails? (web, file shares, login, VPN, RDP, M365)

\- Is it \*\*one user\*\*, \*\*one device\*\*, \*\*one site\*\*, or \*\*everyone\*\*?



\## 2) Confirm basic network state

\- IP address / subnet / gateway present?

\- DNS servers assigned?

\- Can you ping the default gateway?

\- Can you ping a public IP (8.8.8.8)?

\- Can you resolve a name (nslookup google.com)?



\## 3) Identify the failure class (pick one)

\- DHCP / addressing

\- DNS / name resolution

\- Authentication (Kerberos/NTLM)

\- Routing / firewall / VLAN

\- GPO / secure channel / device trust



\## 4) Capture evidence early

\- `ipconfig /all`

\- `route print`

\- `nslookup <name>`

\- Windows Event Viewer highlights (System, DNS Client, Netlogon, Kerberos)



