\# Network vs Identity Boundary Decision Tree



(DNS, Connectivity, Kerberos, Authentication Boundaries)



\*\*Audience:\*\* Tier 2–3 engineers, escalation engineers, on-call responders  

\*\*Purpose:\*\* Determine whether an issue is primarily network-layer or identity-layer before deep troubleshooting



---



\## Why This Exists



Many “identity” failures are \*\*secondary symptoms\*\* of network or DNS issues.  

Likewise, some network tests pass while authentication still fails due to \*\*identity-layer conditions\*\*.



This decision tree exists to:

\- Prevent mis-scoped troubleshooting

\- Avoid unnecessary identity changes

\- Reduce escalation noise

\- Identify the \*correct\* domain of ownership early



Use this \*\*after basic triage\*\* but \*\*before deep identity or network changes\*\*.



---



\## Visual Boundary Decision Tree (ASCII)



```text

START

&nbsp; |

&nbsp; v

\[Can the device reach the network?]

&nbsp; |

&nbsp; +--> No IP / APIPA / wrong VLAN?

&nbsp; |       |

&nbsp; |       v

&nbsp; |   NETWORK ISSUE (stop identity work)

&nbsp; |

&nbsp; +--> IP present + correct subnet

&nbsp;         |

&nbsp;         v

\[Can the device resolve DNS?]

&nbsp;         |

&nbsp;         +--> No name resolution / wrong DNS --> NETWORK/DNS ISSUE

&nbsp;         |

&nbsp;         +--> DNS resolves

&nbsp;                 |

&nbsp;                 v

\[Can the device reach a Domain Controller?]

&nbsp;                 |

&nbsp;                 +--> No ping / ports blocked --> NETWORK ISSUE

&nbsp;                 |

&nbsp;                 +--> DC reachable

&nbsp;                         |

&nbsp;                         v

\[Does Kerberos/authentication fail?]

&nbsp;                         |

&nbsp;                         +--> Yes --> IDENTITY ISSUE

&nbsp;                         |

&nbsp;                         +--> No

&nbsp;                               |

&nbsp;                               v

&nbsp;                     \[Is access to specific services failing?]

&nbsp;                               |

&nbsp;                               +--> Yes --> IDENTITY or APP AUTH PATH

&nbsp;                               |

&nbsp;                               +--> No --> Likely transient or endpoint issue



