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
* status ^short = "State of the medication"
* category ^short = "Type of intended use"
* dosage ^short = "	Details of how medication is/was taken or should be taken."
* effectivePeriod ^short = "Period when the medication is/was or should be used."
[r4-init]
* medication[x] only CodeableConcept or Reference(MedicationEuCore)
* reasonCode ^short = "Coded reason for use"
[r4-end]
[r5-init]
* medication only CodeableReference(MedicationEuCore)
* reason.concept ^short = "Coded reason for use"
[r5-end]



