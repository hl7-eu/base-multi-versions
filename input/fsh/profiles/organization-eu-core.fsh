Profile: OrganizationEuCore
Parent: OrganizationEu
Id: organization-eu-core
Title: "Organization (EU core)"
Description: "This profile sets minimum expectations for the Organization resource common to most of the use cases."
* insert SetFmmandStatusRule ( 2, draft)
[r4-init]
* insert ImposeProfile($Organization-uv-ips, 0)
[r4-end]
* name 1..
* partOf only Reference (OrganizationEuCore)