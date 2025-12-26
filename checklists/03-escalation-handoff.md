\# Escalation Handoff Checklist



This checklist is used \*\*when an issue must be escalated\*\* to a senior engineer, network team, vendor, or external provider.s.



The goal is to ensure escalation is \*\*actionable\*\*, \*\*efficient\*\*, and \*\*does not require rework\*\*.



---



\## 1) Confirm Escalation Criteria Is Met



Escalate only after the following are true:



\- Issue persists after basic triage and remediation attempts

\- Impact exceeds support scope or SLA

\- Requires elevated access, architectural changes, or vendor intervention

\- Multiple users, sites, or services are affected

\- Security or compliance risk is suspected



---



\## 2) Clearly Define the Problem



Provide a \*\*one-sentence summary\*\*:



\- What is broken?

\- Who is affected?

\- Since when?



\*\*Example:\*\*

> Users at Site B cannot authenticate to domain resources after VLAN change at 09:30 CST.



---



\## 3) Environment \& Scope Details



Include \*\*only what matters\*\*:



\- Affected site(s):

\- VLAN / subnet(s):

\- Firewall / gateway involved:

\- Server(s) involved (DC, DNS, file, app):

\- Cloud dependency (Azure, VPN, SaaS, ISP):



---



\## 4) Evidence Collected (Attach or Reference)



Attach outputs or note locations:



\- `ipconfig /all`

\- `route print`

\- `nslookup` results

\- `Test-NetworkBaseline.ps1` output

\- Relevant Event Viewer logs:

&nbsp; - System

&nbsp; - DNS Client

&nbsp; - Netlogon

&nbsp; - Kerberos

\- Firewall or switch logs (if available)



---



\## 5) What Has Already Been Attempted



List \*\*only completed actions\*\*:



\- Configuration checks performed

\- Services restarted

\- Policies verified

\- Devices rebooted

\- Rules reviewed



Avoid speculation — stick to facts.



---



\## 6) Current Impact \& Urgency



Classify clearly:



\- ⬜ Informational

\- ⬜ Degraded service

\- ⬜ Partial outage

\- ⬜ Full outage

\- ⬜ Security-related



Include business impact if known.



---



\## 7) Known Constraints or Risks



Call out anything relevant:



\- Change freeze windows

\- After-hours restrictions

\- Production vs test environment

\- Potential blast radius

\- Compliance concerns



---



\## 8) Escalation Target



Specify \*\*who this is going to\*\*:



\- Internal network team

\- Senior infrastructure engineer

\- Vendor (ISP, firewall, Microsoft, etc.)

\- Security / compliance



Include ticket numbers or vendor case IDs if available.



---



\## 9) Handoff Confirmation



Before closing or transferring:



\- All artifacts attached

\- Summary reviewed for clarity

\- Escalation recipient notified

\- Ticket status updated appropriately



---



\## Design Principle



> A good escalation allows the next engineer to \*\*start where you left off\*\*, not start over.



If escalation feels slow, unclear, or repetitive — improve the handoff, not the escalation path.



