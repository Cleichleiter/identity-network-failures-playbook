\# Identity Failure Triage Checklist

(Login Failures, Kerberos, DNS, Trust Issues)



This checklist is used when users or systems cannot authenticate, access resources,

or establish trusted identity-based connections.



Do NOT attempt fixes until evidence is captured.



---



\## 1) Scope the Failure (Always First)



\- What exactly fails?

&nbsp; - Interactive login

&nbsp; - RDP

&nbsp; - File shares

&nbsp; - VPN

&nbsp; - M365 / cloud auth

\- Who is affected?

&nbsp; - Single user

&nbsp; - Single device

&nbsp; - Multiple users

&nbsp; - Entire site

\- When did it start?

&nbsp; - After reboot?

&nbsp; - After patching?

&nbsp; - After network change?

&nbsp; - After password reset?



---



\## 2) Confirm Network \& DNS Baseline



Identity \*\*cannot\*\* function without DNS.



On the affected system:



\- `ipconfig /all`

&nbsp; - Correct IP?

&nbsp; - Correct subnet?

&nbsp; - Correct default gateway?

&nbsp; - Correct DNS servers (domain DNS, not public)?

\- `ping <default-gateway>`

\- `ping <domain-dns-server>`

\- `nslookup <domain-name>`

\- `nslookup \_ldap.\_tcp.dc.\_msdcs.<domain>`



If DNS resolution fails:

\- STOP

\- Escalate as \*\*DNS / Network\*\*, not identity



---



\## 3) Time \& Kerberos Validation



Kerberos is time-sensitive.



\- Check system time:

&nbsp; - `w32tm /query /status`

\- Verify time skew < 5 minutes from DC

\- If time skew exists:

&nbsp; - Identify time source

&nbsp; - Do NOT force manual time changes without understanding root cause



---



\## 4) Device Trust \& Secure Channel



For domain-joined devices:



\- `nltest /sc\_verify:<domain>`

\- Look for:

&nbsp; - Secure channel failures

&nbsp; - Trust relationship errors

\- Check Event Viewer:

&nbsp; - System

&nbsp; - Netlogon

&nbsp; - Kerberos

\- Common indicators:

&nbsp; - Password reset issues

&nbsp; - Re-imaged device

&nbsp; - Long offline period



---



\## 5) Authentication Evidence (Critical)



Collect before remediation:



\- Event Viewer:

&nbsp; - Security

&nbsp; - System

&nbsp; - Kerberos

&nbsp; - Netlogon

\- Error codes:

&nbsp; - 0xC000006A

&nbsp; - 0xC000006D

&nbsp; - KRB\_AP\_ERR\_SKEW

\- Screenshot or export logs if escalating



---



\## 6) Determine Failure Class



Choose ONE primary failure path:



\- DNS resolution failure

\- Time synchronization failure

\- Secure channel / trust failure

\- Account lockout / password issue

\- Network segmentation / firewall blocking auth ports

\- GPO or security policy issue



---



\## 7) Escalation Criteria



Escalate immediately if:



\- Multiple users affected

\- DC unreachable

\- DNS SRV records missing

\- Kerberos errors persist after time validation

\- Secure channel broken on multiple devices

\- Authentication failures across VLANs or sites



---



\## 8) What NOT to Do



\- Do NOT reset passwords blindly

\- Do NOT remove/rejoin domain without evidence

\- Do NOT flush DNS without understanding scope

\- Do NOT reboot DCs as a first step



---



\## 9) Handoff Summary (If Escalating)



Provide:



\- Who is affected

\- What fails

\- When it started

\- DNS status

\- Time status

\- Trust status

\- Relevant logs / error codes



This allows the next engineer to act without repeating work.



