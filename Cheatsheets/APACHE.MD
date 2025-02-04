Apache 

#FUZZ the Apache urls : 
Wordlist:
1. https://github.com/danielmiessler/SecLists/blob/master/Discovery/Web-Content/Apache.fuzz.txt
2. https://fossies.org/linux/honggfuzz/examples/apache-httpd/README.md
3. https://github.com/random-robbie/bruteforce-lists/blob/master/honey.txt

#Always check the Plugins and Misconfiguration in them there might be few more endpointsg etting disclosed

#Here are few CVEs to Check and make Notes
CVE-2021-44228 - Log4Shell: Remote Code Execution in Apache Log4j
CVE-2021-45046 - Apache Log4j Security Bypass
CVE-2021-41773 - Path Traversal in Apache HTTP Server 2.4.49
CVE-2021-42013 - Path Traversal and RCE in Apache HTTP Server 2.4.49 and 2.4.50
CVE-2022-36732 - Arbitrary File Read in Apache HTTP Server
CVE-2017-5638 - Remote Code Execution in Apache Struts2
CVE-2017-9805 - RCE in Apache Struts2 REST Plugin
CVE-2019-0232 - Apache Tomcat RCE via JSP
CVE-2022-42889 - Apache Commons Text Injection Vulnerability
CVE-2020-13935 - WebSocket Denial of Service (DoS) in Apache Tomcat
CVE-2022-25762 - Remote Code Execution in Apache OFBiz
CVE-2018-11776 - Critical RCE in Apache Struts2
CVE-2018-1335 - Deserialization Flaw in Apache ActiveMQ
CVE-2020-9484 - Apache Tomcat Session Deserialization RCE
CVE-2021-27578 - Weak Access Control in Apache HTTP Server
CVE-2018-11759 - DoS in Apache HTTP Server's HTTP/2 Module
CVE-2021-40438 - SSRF in Apache HTTP Server's mod_proxy
CVE-2019-12406 - Remote Code Execution in Apache Solr
CVE-2019-0199 - DoS Vulnerability in Apache HTTP Server
CVE-2020-13942 - SSRF in Apache OFBiz
CVE-2019-10072 - Cross-Site Scripting (XSS) in Apache HTTP Server
CVE-2017-3167 - Weak Authentication Mechanism in Apache HTTP Server
CVE-2017-7657 - DoS in Apache Kafka
CVE-2018-11784 - HTTP/2 Push Diary DoS in Apache HTTP Server
CVE-2020-1945 - Code Execution Vulnerability in Apache Kafka Connect
CVE-2018-11776 - RCE via Incorrect Namespace Handling in Struts2
CVE-2016-0736 - SSL Vulnerability in Apache Traffic Server
CVE-2019-10086 - Memory Corruption in Apache Thrift
CVE-2021-31805 - XSS in Apache Struts2
CVE-2019-0199 - Apache HTTP Server Vulnerability Leading to DoS


#Few Links to Explore
1. https://hackerone.com/reports/520903
2. https://activemq.apache.org/components/artemis/documentation/hacking-guide/
3. https://book.hacktricks.xyz/network-services-pentesting/pentesting-web/apache
4. https://www.acunetix.com/websitesecurity/apache-security/
5. https://hackerone.com/reports/2453322
6. https://github.com/nahamsec/Resources-for-Beginner-Bug-Bounty-Hunters/blob/master/assets/blogposts.md
7. https://medium.com/@zpbrent/how-i-find-my-first-internet-bug-bounty-for-apache-airflow-9d3c1ec29b24
8. https://blog.intigriti.com/bug-bytes/bug-bytes-143-building-an-apache-ssrf-exploit-thesis-on-http-request-smuggling-turbo-intruder-go-brrr
9. https://portswigger.net/daily-swig/internet-bug-bounty-high-severity-vulnerability-in-apache-http-server-could-lead-to-rce
10. https://animal0day.blogspot.com/2017/07/from-fuzzing-apache-httpd-server-to-cve.html
11. https://blog.securitybreached.org/2020/03/31/microsoft-rce-bugbounty/
12. https://hackerone.com/reports/2401359
13. https://hackerone.com/reports/2677187
14. https://hackerone.com/reports/1594627
15. https://hackerone.com/reports/2612028
