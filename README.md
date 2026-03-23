# RVTools Multi-vCenter Export Automation

A PowerShell-based infrastructure automation solution for executing RVTools exports across multiple VMware vCenters, validating generated reports, and enabling repeatable reporting workflows for virtualization teams.



## 🚀 Overview

In large VMware environments, collecting inventory and configuration data from multiple vCenters is often repetitive, time-consuming, and prone to inconsistencies when performed manually.

This project automates that workflow by:
- reading target vCenters from a structured input file
- mapping credentials by environment
- validating connectivity before execution
- executing RVTools exports in a repeatable manner
- validating generated output files
- organizing results into actionable categories

The goal is to improve operational efficiency, reduce manual effort, and standardize infrastructure reporting processes.



## 🎯 Why This Project Matters

Infrastructure teams frequently rely on tools like RVTools for visibility into VMware environments. However, scaling this across multiple vCenters introduces operational challenges.

This solution addresses those challenges by providing:
- a reusable automation framework
- consistent execution across environments
- improved visibility into success and failure conditions
- a foundation for scalable reporting workflows



## ⚙️ Features

- Multi-vCenter RVTools export automation
- Environment-based credential mapping (PROD / MGMT / LAB)
- Integration with Windows Credential Manager
- Automated password encryption for RVTools execution
- Connectivity validation (pre-check)
- Output validation using file size integrity checks
- Structured result categorization:
  - Successful exports
  - Authentication failures
  - Invalid or incomplete exports
  - Unreachable systems
  - Missing credentials
- Optional ZIP packaging of reports
- Optional email summary notification



## 🧠 Technical Highlights

- PowerShell-based infrastructure automation
- VMware PowerCLI integration
- CredentialManager integration for secure credential handling
- Multi-environment credential abstraction
- Externalized input configuration (vCenter list)
- Execution flow control with error handling
- Output validation and reporting classification
- Designed for repeatable operational workflows


## 🏗️ Project Structure
.

├── 00_RVTools_Export.ps1 # Main automation script

├── RVToolsPasswordEncryption.ps1 # Password encryption helper

└── vCenterLoginAccount.txt # Input file (vCenter list)



## 📥 Input Configuration

 vCenter Input File
`vCenterLoginAccount.txt`

Format:
vcenter01.example.com|PROD
vcenter02.example.com|MGMT
vcenter03.example.com|LAB

- First value: vCenter FQDN
- Second value: environment scope (used for credential mapping)


## 🔐 Credential Setup

This script uses **Windows Credential Manager** for secure credential storage.

Example:

powershell
New-StoredCredential -Target "Creds_Prod" -UserName "username" -Password "password" -Persist LocalMachine
Example Credential Mapping

Environment	Credential Target
PROD	Creds_Prod
MGMT	Creds_Mgmt
LAB	Creds_Lab


## ▶️ How to Run
.\00_RVTools_Export.ps1

## 📊 Output

The script generates:

Individual Excel reports for each vCenter
Execution summary including:
Successful exports
Authentication failures
Invalid exports
Unreachable systems
Missing credentials
Optional ZIP archive of reports

## 🧩 How It Works
Reads vCenter list from input file
Maps environment scope to credential target
Validates connectivity using ping test
Retrieves credentials from Credential Manager
Connects to vCenter using VMware PowerCLI
Encrypts password for RVTools compatibility
Executes RVTools export command
Validates output file size
Categorizes execution results
Generates structured summary

## ⚙️ Requirements
Windows PowerShell 5.1 or higher
RVTools installed
VMware PowerCLI module
CredentialManager module
Install Required Modules
Install-Module VMware.PowerCLI
Install-Module CredentialManager

## 🧱 Design Approach

This project was designed with the following principles:

Reusability across multiple environments
Separation of input data from execution logic
Secure handling of credentials
Operational visibility through categorized results
Simplicity for easy adaptation and extension

## 📈 Operational Impact

This automation helps infrastructure teams:

Reduce repetitive manual export tasks
Improve consistency in reporting workflows
Identify connectivity and authentication issues quickly
Standardize multi-environment data collection
Support audit, migration, and capacity planning activities

## 🔮 Potential Extensions

This project can be extended to support:

Scheduled execution via Task Scheduler
Centralized report archival
HTML or dashboard-based reporting
Integration with monitoring systems
Additional export modes and filters

## 🔒 Security Notes

This repository is sanitized for public sharing:

No real vCenter hostnames
No real credentials
No internal email addresses
No organization-specific data

## ⚠️ Disclaimer

This project is provided as a reference implementation for infrastructure automation.

Please review, test, and adapt it according to your environment before using in production.

## 👨‍💻 Author Note

This project reflects hands-on work in infrastructure automation, virtualization operations, and repeatable reporting design.
It is published in sanitized form to demonstrate practical automation techniques for VMware-based environments.
