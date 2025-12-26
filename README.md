Identity + Network Failures Playbook



Practical playbooks and diagnostic scripts for troubleshooting the most common

“the network is up, but nothing works” scenarios in Windows environments.



This repository focuses on the failure boundary between network connectivity, DNS, and identity services (Active Directory, Kerberos, device trust, and authentication).



The goal is not guesswork — it is fast, repeatable diagnosis and evidence-driven escalation.



Design Philosophy



Boundary first

Determine whether the failure is network/DNS or identity before touching accounts, policies, or servers.



Actionable, not theoretical

Each checklist and playbook is written to be followed during a live incident.



Minimal assumptions

Steps are designed to confirm or deny conditions explicitly instead of relying on “it should work.”



Evidence-based escalation

Every path ends with clear guidance on what to capture before handing off or escalating.



Intended Audience



System and network engineers supporting Windows environments



MSP engineers who need consistent, repeatable troubleshooting workflows



On-call and escalation engineers diagnosing authentication or name-resolution failures



Anyone who needs to isolate identity vs network issues quickly under pressure



Repository Structure



checklists/

Fast triage checklists and “before escalation” validation steps



playbooks/

Deep-dive troubleshooting guides by symptom or failure mode



scripts/

Lightweight PowerShell diagnostic tools used to establish boundaries and gather evidence



examples/

Sample outputs and sanitized artifacts suitable for documentation or tickets



diagrams/

Simple dependency maps (for example: DHCP → DNS → AD authentication)



How to Use This Repository



Start with a checklist

Confirm scope, basic connectivity, and observable symptoms.



Run boundary scripts

Use scripts to determine whether the issue belongs to:



Network / DNS



Identity / authentication



Or is not applicable due to missing domain context



Follow the appropriate playbook

Only after the boundary is proven should deeper identity or policy changes be attempted.



Escalate with evidence

Use the provided handoff checklists to ensure clean, actionable escalation.



Quick Start (Local)



The boundary test script determines where troubleshooting should occur, not how to fix the issue.



cd "C:\\Repos\\identity-network-failures-playbook"



\# 1) Non-domain device or off-network

.\\scripts\\Test-NetworkIdentityBoundary.ps1 -Verbose

\# Expected result: NO DOMAIN CONTEXT



\# 2) Domain context provided, but DC/SRV/ports fail

.\\scripts\\Test-NetworkIdentityBoundary.ps1 -Domain "contoso.com" -Dc "dc01.contoso.com" -Verbose

\# Expected result: NETWORK/DNS PATH



\# 3) Healthy domain context (run on a domain-joined system)

.\\scripts\\Test-NetworkIdentityBoundary.ps1 -Domain "yourdomain.com" -Dc "yourdc.yourdomain.com" -Verbose

\# Expected result: IDENTITY PATH



Interpreting Boundary Results

Classification	Meaning

NO DOMAIN CONTEXT	Device is not domain-joined or cannot see domain services. Identity troubleshooting is not applicable yet.

NETWORK/DNS PATH	Core prerequisites (DNS, SRV records, DC reachability, ports) are failing. Fix network/DNS before identity changes.

IDENTITY PATH	Network and DNS prerequisites are healthy. Proceed to Kerberos, trust, user, or policy troubleshooting.

Key Principle



Do not fix what you haven’t proven broken.



Most identity failures are secondary symptoms of DNS, time synchronization, or network reachability issues.

This repository exists to prevent unnecessary disruption, repeated fixes, and misdirected troubleshooting.

