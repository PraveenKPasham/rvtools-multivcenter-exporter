# RVTools Multi-vCenter Export Automation

A PowerShell automation script to execute RVTools exports across multiple VMware vCenters, validate output files, and generate structured reporting for infrastructure teams.

---

##  Overview

This project automates the process of collecting RVTools reports from multiple vCenters using stored credentials. It helps reduce manual effort, standardize reporting, and improve operational efficiency in VMware environments.

---

##  Features

- Execute RVTools exports across multiple vCenters
- Support for multiple environments (PROD / MGMT / LAB)
- Credential mapping using Windows Credential Manager
- Automated password encryption for RVTools execution
- Connectivity validation before execution
- Output validation (file size check)
- Categorized reporting:
  - Successful exports
  - Authentication failures
  - Invalid or incomplete exports
  - Unreachable systems
  - Missing credentials
- Optional ZIP packaging of reports
- Optional email summary notification

---

##  Project Structure
├── 00_RVTools_Export.ps1 # Main automation script
├── RVToolsPasswordEncryption.ps1 # Password encryption helper
└── vCenterLoginAccount.txt # Input file with vCenter list


---

##  Input File Format

`vCenterLoginAccount.txt`

Each line should follow this format:
vcenter01.example.com|PROD
vcenter02.example.com|MGMT
vcenter03.example.com|LAB

- First value = vCenter FQDN
- Second value = environment scope (used for credential mapping)

---

##  Credential Setup

This script uses **Windows Credential Manager**.

Store credentials like this:

powershell
New-StoredCredential -Target "Creds_Prod" -UserName "username" -Password "password" -Persist LocalMachine

Example mapping (inside script):

Scope	Credential Target
PROD	Creds_Prod
MGMT	Creds_Mgmt
LAB 	Creds_Lab


##  How To Run
.\00_RVTools_Export.ps1



##  Output

The script generates:

Excel files per vCenter
Categorized execution summary:
Success
Authentication failure
Invalid export
Not reachable
Missing credentials
Optional ZIP archive of reports

##  How It Works
Reads vCenter list from input file
Maps environment to credential target
Validates connectivity (ping test)
Retrieves credentials from Credential Manager
Connects to vCenter using PowerCLI
Encrypts password for RVTools
Executes RVTools export
Validates output file
Categorizes results
Generates summary report

##  Requirements
Windows PowerShell 5.1 or higher
RVTools installed
VMware PowerCLI module
CredentialManager module

Install required modules:

Install-Module VMware.PowerCLI
Install-Module CredentialManager

##  Disclaimer

This script is provided as a reference implementation for infrastructure automation.
Please review, test, and adapt it according to your environment before production use.

##  Use Case

This automation is useful for:

VMware infrastructure teams
Data center operations teams
Periodic inventory and audit reporting
Migration and capacity planning activities

##  Author
Praveen K Pasham : Developed as part of infrastructure automation workflows to improve efficiency and consistency in multi-vCenter environments
