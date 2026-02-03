Profile: OrganizationEuCore
Parent: OrganizationEu
Id: organization-eu-core
Title: "Organization (EU core)"
Description: """This profile introduce essential constraints and extensions for the Organization resource that apply across multiple use cases."""
* insert SetFmmandStatusRule (2, trial-use)
[r4-init]
* insert ImposeProfile($Organization-uv-ips, 0)
[r4-end]
* name 1..
* partOf only Reference (OrganizationEuCore)