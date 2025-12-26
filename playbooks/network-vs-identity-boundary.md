Network vs Identity Boundary Decision Tree

(DNS, Connectivity, Kerberos, Authentication Boundaries)

Audience: Tier 2–3 engineers, escalation engineers, on-call responders
Purpose: Determine whether an issue is primarily network-layer or identity-layer before deep troubleshooting

Why This Exists

Many “identity” failures are secondary symptoms of network or DNS issues.
Likewise, some network tests pass while authentication still fails due to identity-layer conditions.

This decision tree exists to:

Prevent mis-scoped troubleshooting

Avoid unnecessary identity changes

Reduce escalation noise

Identify the correct ownership domain early

Use this after basic triage but before deep identity or network changes.

## Visual Boundary Decision Tree (ASCII)

```text
START
  |
  v
[Can the device reach the network?]
  |
  +--> No IP / APIPA / wrong VLAN?
  |       |
  |       v
  |   NETWORK ISSUE (stop identity work)
  |
  +--> IP present + correct subnet
          |
          v
[Can the device resolve DNS?]
          |
          +--> No name resolution / wrong DNS
          |       |
          |       v
          |   NETWORK / DNS ISSUE
          |
          +--> DNS resolves
                  |
                  v
[Can the device reach a Domain Controller?]
                  |
                  +--> No ping / ports blocked
                  |       |
                  |       v
                  |   NETWORK ISSUE
                  |
                  +--> DC reachable
                          |
                          v
[Does Kerberos or authentication fail?]
                          |
                          +--> Yes
                          |       |
                          |       v
                          |   IDENTITY ISSUE
                          |
                          +--> No
                                |
                                v
[Is access to specific services failing?]
                                |
                                +--> Yes --> IDENTITY or APPLICATION AUTH PATH
                                |
                                +--> No  --> Likely transient or endpoint issue


Key Boundary Rules

No IP, wrong VLAN, or bad gateway
→ Network issue. Stop identity troubleshooting.

DNS resolution fails or AD SRV records missing
→ Network/DNS issue. Identity services cannot function.

DC unreachable or core ports blocked (88/389/445/135)
→ Network issue.

Network and DNS healthy, but authentication fails
→ Identity-layer issue (Kerberos, trust, user policy, time).

Related Artifacts

Boundary validation script:
scripts/Test-NetworkIdentityBoundary.ps1

Identity deep dive:
playbooks/identity-failure-decision-tree.md

Escalation preparation:
checklists/03-escalation-handoff.md

Principle to Remember

Identity troubleshooting without validating the network boundary first is guesswork.

This decision tree exists to ensure the right problem is being solved before changes are made.