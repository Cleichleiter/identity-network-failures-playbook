\# Identity Failure Decision Tree

(Login, Kerberos, DNS, Trust Issues)



This decision tree guides engineers through structured decision-making

when diagnosing identity and authentication failures in Windows environments.



Use this \*\*after initial triage\*\* and evidence collection.

## Visual Decision Tree (ASCII)

```text
START
  |
  v
[Scope the failure]
  |
  +--> Everyone / Entire site?
  |       |
  |       v
  |   [Check DC reachability + DNS health]
  |       |
  |       +--> DNS fails / DC unreachable --> NETWORK/DNS PATH (stop identity fixes)
  |       |
  |       +--> DNS OK + DC reachable ------> Continue
  |
  +--> Single user or single device?
          |
          v
      [Check DNS + SRV records]
          |
          +--> nslookup domain fails / SRV missing --> DNS PATH (stop)
          |
          +--> DNS OK
                  |
                  v
            [Check time sync]
                  |
                  +--> Time skew > 5 min --> Fix NTP/W32Time --> Retest
                  |
                  +--> Time OK
                          |
                          v
                  [Kerberos indicators?]
                          |
                          +--> Yes --> Validate: time, DNS SRV, KDC reachability, SPNs (if service)
                          |            |
                          |            v
                          |         Retest auth
                          |
                          +--> No
                                |
                                v
                      [Device trust / secure channel OK?]
                                |
                                +--> Broken --> Repair trust / rejoin domain --> Retest
                                |
                                +--> Healthy
                                       |
                                       v
                           [User-specific issue?]
                                       |
                                       +--> Yes --> Lockout/disabled/expired/access/MFA/CA policies
                                       |
                                       +--> No
                                             |
                                             v
                                    [GPO / policy change?]
                                             |
                                             +--> Yes --> Identify offending policy --> Rollback/adjust
                                             |
                                             +--> No --> Escalate with evidence packet




---



\## STEP 1 — Scope the Failure



\*\*Question:\*\* Who is affected?



\- \[ ] Single user

\- \[ ] Multiple users

\- \[ ] Single device

\- \[ ] Entire site

\- \[ ] Entire environment



\*\*Decision:\*\*

\- Single user/device → likely endpoint, profile, or trust issue

\- Multiple users/single site → likely DNS, time, DC reachability, or VLAN

\- Everyone → likely AD, DNS, firewall, or DC outage



---



\## STEP 2 — Can the device reach domain services?



From the affected device:



\- Can it ping a Domain Controller?

\- Can it resolve the domain via DNS?

\- Can it reach port 88 (Kerberos) and 389/445 (LDAP/SMB)?



\*\*If NO:\*\*

→ Treat as \*\*network/DNS issue\*\*

→ Pivot to network troubleshooting playbook



\*\*If YES:\*\*

→ Continue to identity checks



---



\## STEP 3 — Is time synchronization healthy?



Check:

\- Local system time

\- Domain Controller time

\- Time skew > 5 minutes?



\*\*If skewed:\*\*

→ Kerberos authentication will fail

→ Fix time source (NTP / w32time)

→ Retest authentication



\*\*If time is correct:\*\*

→ Continue



---



\## STEP 4 — Is this a Kerberos or credential failure?



Indicators:

\- Event IDs: 4768, 4769, 4771

\- Errors like:

&nbsp; - KRB\_AP\_ERR\_SKEW

&nbsp; - KDC\_ERR\_PREAUTH\_FAILED

&nbsp; - Clock skew / ticket expired



\*\*If Kerberos-related:\*\*

\- Validate:

&nbsp; - Time sync

&nbsp; - DNS SRV records

&nbsp; - SPNs (if service account involved)



\*\*If not Kerberos-related:\*\*

→ Continue



---



\## STEP 5 — Is the device trust broken?



From the endpoint:

\- Errors logging in with cached credentials?

\- Secure channel errors?

\- Event IDs: 5722, 3210, 40960/40961



\*\*If trust is broken:\*\*

→ Reset computer account or rejoin domain



\*\*If trust is healthy:\*\*

→ Continue



---



\## STEP 6 — Is the issue user-specific?



Check:

\- User can log in elsewhere?

\- Account locked or disabled?

\- Password expired?

\- MFA / conditional access policies?



\*\*If user-specific:\*\*

→ Address account policy, profile, or access assignment



\*\*If not:\*\*

→ Continue



---



\## STEP 7 — Is Group Policy involved?



Check:

\- Recent GPO changes

\- Device OU placement

\- gpresult /h output

\- Security filtering or WMI filters



\*\*If GPO implicated:\*\*

→ Isolate policy impact

→ Roll back or adjust



---



\## STEP 8 — Escalation Decision



Escalate when:

\- Root cause spans multiple layers (network + identity)

\- Domain-wide authentication is impacted

\- Evidence points to AD/DNS infrastructure failure

\- Changes risk broader impact



\*\*Escalation package should include:\*\*

\- Scope summary

\- Timeline

\- Logs and command output

\- What has already been ruled out



---



\## Key Principle



> Do not fix what you haven’t proven broken.



Identity failures are often \*\*secondary symptoms\*\* of DNS, time, or network issues.

This tree exists to prevent guesswork and repeated disruption.



