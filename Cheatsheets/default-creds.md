# Default Credentials

Source of truth: [ihebski/DefaultCreds-cheat-sheet](https://github.com/ihebski/DefaultCreds-cheat-sheet)
— pulls from Seclists, cirt.net, and vendor docs. ~2000 vendors, full CSV:
[DefaultCreds-Cheat-Sheet.csv](https://raw.githubusercontent.com/ihebski/DefaultCreds-cheat-sheet/main/DefaultCreds-Cheat-Sheet.csv)

## Install and use the `creds` CLI

```bash
pip install defaultcreds
creds search tomcat
creds search "cisco (ssh)"
creds update
```

## Grep the CSV directly

```bash
curl -sO https://raw.githubusercontent.com/ihebski/DefaultCreds-cheat-sheet/main/DefaultCreds-Cheat-Sheet.csv

# lookup by vendor
awk -F',' 'tolower($1) ~ /tomcat/' DefaultCreds-Cheat-Sheet.csv

# lookup by username
awk -F',' '$2 == "admin"' DefaultCreds-Cheat-Sheet.csv | head

# unique vendors
awk -F',' 'NR>1{print $1}' DefaultCreds-Cheat-Sheet.csv | sort -u | wc -l
```

## Top vendors worth brute-checking first

Apache Tomcat · Jenkins · Jira · JBoss · ActiveMQ · GlassFish · WebLogic
Grafana · Kibana · Elasticsearch · Neo4j (bloodhound) · Cacti · Nagios
phpMyAdmin · Adminer · Bookstack · Guacamole · Couchbase · Couchdb
Cassandra · ClickHouse · ArangoDB · db2
Cisco · Juniper · Fortinet · Palo Alto · Aruba · Ruckus · Mikrotik · pfSense
HP iLO · Dell iDRAC · Supermicro IPMI · ASUS BMC · Cisco IMC
Brother / Canon / Epson / Konica / Ricoh / Xerox printers
Hikvision · Dahua · Axis · acti · avigilon · Amcrest (IP cams)
APC UPS · Eaton UPS · CyberPower
Tenda · TP-Link · D-Link · Netgear · Ubiquiti · ASUS · Belkin (home gear)

## High-signal examples from the sheet

| Product | Username | Password |
|---|---|---|
| Tomcat manager | admin | admin |
| Tomcat manager | tomcat | tomcat |
| Tomcat manager | tomcat | s3cret |
| Jenkins (old) | admin | admin |
| Neo4j / BloodHound | neo4j | BloodHound |
| Neo4j / BloodHound | neo4j | neo4j |
| Grafana | admin | admin |
| Cacti | admin | admin |
| Bookstack | admin@admin.com | password |
| Guacamole | guacadmin | guacadmin |
| Couchbase web | Administrator | password |
| Couchdb | admin | password |
| Cassandra | cassandra | cassandra |
| ArangoDB | root | *(blank)* |
| ClickHouse | default | *(blank)* |
| Argo Workflows | admin | admin |
| Artifactory | admin | password |
| Apache Airflow | airflow | airflow |
| MongoDB (no auth) | — | — |
| Redis (no auth) | — | — |
| Docker API 2375 | — | — |
| Kubernetes Dashboard | — | — |
| Dell iDRAC | root | calvin |
| HP iLO | Administrator | *(sticker random)* |
| Supermicro IPMI | ADMIN | ADMIN |
| APC UPS web | apc | apc |
| Cisco (many) | admin | cisco |
| Cisco (many) | cisco | cisco |
| MikroTik (old) | admin | *(blank)* |
| Ubiquiti UniFi | ubnt | ubnt |
| pfSense | admin | pfsense |
| Jira (internal) | admin | admin |
| SolarWinds Orion | admin | *(blank)* |

## Scan tools that bake in defaults

- [`changeme`](https://github.com/ztgrace/changeme) — CLI that speaks 100+ protocols with built-in default creds
- [`hydra`](https://github.com/vanhauser-thc/thc-hydra) — `-L users.txt -P passwords.txt` with `-C defaults.txt`
- Metasploit `auxiliary/scanner/*/*_login`
- Nuclei — `nuclei -tags default-login`

## Related lists

- [SecLists Default-Credentials](https://github.com/danielmiessler/SecLists/tree/master/Passwords/Default-Credentials)
- [Many-Passwords/many-passwords](https://github.com/many-passwords/many-passwords)
- [cirt.net passwords](https://cirt.net/passwords)
