Microsoft 365 PowerShell
===============

## Description

This repository contains a collection of PowerShell scripts designed specifically for interacting with Microsoft 365.
I have researched and written these scripts with the intention of maximizing effectiveness and productivity.
The repo is under development, please feel free to follow for updates.

## License and disclaimer

This repository is licensed under the MIT License.
See the **LICENSE** file for more information and details.

All PowerShell scripts are available for use with no liability to the user or devices that downloads and executes the scripts contained herein.
It is best practice to thoroughly review and test scripts or software downloaded from the internet in a segregated network or laboratory environment prior to production use.
Always make sure you have permission to execute or download scripts and software for use (**with caution**) on your network.

## Prerequisites

- [ ] A system running the most current version of PowerShell.
- [ ] Microsoft Exchange Online PowerShell module.
- [ ] Microsoft Graph PowerShell module.
- [ ] A valid and provisioned Microsoft 365 tenant.
- [ ] Valid and active administrator role in your Microsoft 365 tenant.

## Install PowerShell

### Linux

To download PowerShell to use on Linux use the following command:

```
snap install powershell --channel=lts/stable --classic
```

### MacOS

To download PowerShell to use on MacOS use the following command:

```
brew install --cask powershell
```

### Run PowerShell (Linux and MacOS)

```
pwsh
```

## Script requirements

I am developing scripts to make use of a PowerShell data file (`.psd1`) that I have named `mstenant.psd1`.
This file can be populated with information about your specific Microsoft 365 tenant.
The reason is so that scripts that require specific information about the Microsoft 365 tenant (i.e. the domain) can be easily accessed by the script.
It is up to you to download `mstenant.psd1` and customize it to your specific environment.

## Contribution guidelines

I welcome contributions and recommendations to improve and expand the quality.
If you have suggestions or would like to contribute I ask one of the following steps to be taken:

1. Submit an issue if something is not working as it should.
2. Submit a pull request with a detailed description of your changes and what you are fixing.

