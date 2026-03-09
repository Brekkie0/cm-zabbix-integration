📄 Zabbix x Open Text Content Manager Integration Script

A Bash utility for authenticating to the CM-API using Kerberos and deploying a 1KB test file to a specified record via Zabbix‑provided macros.

🚀 Overview

This script is designed for automated health checks or integration testing within environments that use Zabbix and Open-Text Content Manager (CM).
It performs the following actions:

    Validates required Zabbix macro inputs

    Acquires a Kerberos ticket

    Authenticates to the CM-API

    Generates a file

    Creates a record in a specified container and uploads a file to it.

    Returns 1 on success or 0 on failure

📦 Features

    Kerberos authentication (kinit)

    HTTP/Negotiate authentication via curl

    Automatic cleanup of temporary files

    Uploads a test file using multipart form data

    Designed for Zabbix automation workflows

🧩 Requirements

Ensure the following are available on the host running the script:

    Bash (v4+ recommended)

    curl with Negotiate/Kerberos support

    Properly configured Kerberos
    
    kinit (Kerberos client utilities)

    Valid Kerberos configuration and CM service principal access

    Zabbix macros providing required parameters (advise against hard-coded credentials)


⚠️ Notes & Caveats

    Kerberos authentication must be correctly configured on the host.

    Hardcoded cookies in the upload request may need updating depending on your CM environment.

    This is my first script and Git repo. Be nice.
