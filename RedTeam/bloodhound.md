# BloodHound

BloodHound is a single-page JavaScript web application, built on top of a Neo4j database, designed to reveal the hidden and often unintended relationships within an Active Directory environment. Attackers can use BloodHound to easily identify highly complex attack paths that would otherwise be impossible to quickly identify. Defenders can use BloodHound to identify and remediate those same attack paths.

## Installation

BloodHound consists of two main components: the BloodHound GUI (a desktop application) and a Neo4j graph database. The data is collected using a C# ingestor called SharpHound.

1. Install Neo4j Desktop from https://neo4j.com/download/ and set up a new local graph database.
2. Download the BloodHound GUI from https://github.com/BloodHoundAD/BloodHound/releases.
3. Download SharpHound.exe from the same releases page.

Note: BloodHound CE (Community Edition) is the actively maintained successor — https://github.com/SpecterOps/BloodHound. Legacy BloodHound above is legacy.

## Data Collection (SharpHound)

SharpHound runs on a domain-joined Windows machine with a domain user account.

```powershell
SharpHound.exe -c All
SharpHound.exe -c Group,Session,ACL,Container,GPO,Trust,OU,SPN,LocalGroup,RDP,DCOM,LoggedOn,ObjectProps,DCOnly
SharpHound.exe -d DOMAIN.COM -u username -p password -o output.zip
```

After collection, a `.zip` file is generated. Import it into the BloodHound GUI.

## Basic Usage (GUI)

1. Start Neo4j.
2. Launch BloodHound, connect with Neo4j credentials (default: `neo4j`/`neo4j`).
3. Upload Data — select the SharpHound `.zip`.

## Common Queries

BloodHound uses Cypher. Built-in queries:

- Shortest Path to Domain Admins
- Find Principals with DCSync Rights
- Find Unconstrained Delegation
- Find Kerberoastable Users

Custom Cypher examples:

```cypher
-- Computers where a user is local admin
MATCH (u:User {name:'USERNAME@DOMAIN.COM'}), (c:Computer)
WHERE (u)-[:AdminTo]->(c)
RETURN u,c

-- Find all users with path to DA
MATCH (u:User),(g:Group {name:'DOMAIN ADMINS@DOMAIN.COM'}),
p=shortestPath((u)-[*1..]->(g))
RETURN p

-- Find computers with unconstrained delegation
MATCH (c:Computer {unconstraineddelegation:true})
RETURN c.name

-- Find AS-REP roastable users
MATCH (u:User {dontreqpreauth:true})
RETURN u.name
```

## References

- BloodHound CE — https://github.com/SpecterOps/BloodHound
- Legacy BloodHound — https://github.com/BloodHoundAD/BloodHound
- SharpHound — https://github.com/BloodHoundAD/SharpHound
- BloodHound documentation — https://support.bloodhoundenterprise.io/hc/en-us
- MITRE ATT&CK T1482 (Domain Trust Discovery) — https://attack.mitre.org/techniques/T1482/
