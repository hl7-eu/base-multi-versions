//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Profile:  MedicationStatementEuCore
Parent:   MedicationStatement
Id:       medicationStatement-eu-core
Title:    "MedicationStatement (EU core) [WIP]"
Description: """This profile sets minimum expectations for the MedicationStatement resource common to most of the use cases.
This profile is adapted from the MPD work."""
//-------------------------------------------------------------------------------------------

* insert SetFmmandStatusRule (1, draft)


* identifier 
  * ^short = "Medication Statement Identifier"
// * status ^short = "Current state of the dispensation"
* subject only Reference( PatientEuCore )
[r4-init]
* medication[x] only CodeableConcept or Reference(MedicationEuCore)
[r4-end]
[r5-init]
* medication only CodeableReference(MedicationEuCore)
[r5-end]



