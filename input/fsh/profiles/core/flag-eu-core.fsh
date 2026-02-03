//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Profile:  FlagEuCore
Parent:   Flag
Id:       flag-eu-core
Title:    "Flag (EU core)"
Description: """This profile introduce essential constraints and extensions for the Flag resource that apply across multiple use cases."""
//-------------------------------------------------------------------------------------------

// * insert SetFmmandStatusRule (1, draft)

* identifier ^short = "Alert bussiness Identifier"
* extension contains $flag-detail named flagDetailExt 0..*
* extension contains $flag-priority named flagPriorityExt 0..1
* extension contains $note named note 0..*
* extension[flagDetailExt]
* extension[flagPriorityExt]
* extension[note]
* status ^short = "Alert status"
* code ^short = "Coded or textual message to display to user."
* subject only Reference(PatientEuCore)
* period ^short = "Time period when the alert is active"