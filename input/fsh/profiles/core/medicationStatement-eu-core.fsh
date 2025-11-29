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
[r4-init]
// should be removed ?
* statusReason ^short = "Reason for the 'exception' statuses of the medication"
[r4-end]
* category ^short = "Type of intended use"
[r4-init]
  * ^binding.extension[+].url = "http://hl7.org/fhir/tools/StructureDefinition/additional-binding"
  * ^binding.extension[=].extension[+].url =  #purpose
  * ^binding.extension[=].extension[=].valueCode =  #preferred
  * ^binding.extension[=].extension[+].url = #valueSet
  * ^binding.extension[=].extension[=].valueCanonical =  Canonical(MedicationIntendedUseEuVs)
  * ^binding.extension[=].extension[+].url = "documentation"
  * ^binding.extension[=].extension[=].valueMarkdown = "When category is used for describing the intended use of the medication (e.g. Prophylactic use)."
[r4-end]
[r5-init]
  * ^binding.additional[+].purpose = #preferred
  * ^binding.additional[=].valueSet = Canonical(MedicationIntendedUseEuVs)
  * ^binding.additional[=].documentation = "When category is used for describing the intended use of the medication (e.g. Prophylactic use)."
/* Slice cannot be used in R4
* category insert SliceElement ( #value, $this )
* category contains intendedUse 0..*
* category[intendedUse] from medicationIntendedUseEuVs
*/
[r5-end]
* dosage ^short = "	Details of how medication is/was taken or should be taken."
  * route //copy the additional bindign from the ips
* effectivePeriod ^short = "Period when the medication is/was or should be used."
[r4-init]
* medication[x] only CodeableConcept or Reference(MedicationEuCore)
* medication[x] from $medication-uv-ips (example)
* extension contains $medicationStatement-adherence-r5 named adherence 0..1
* extension[adherence].extension[code] ^short = "Type of adherence."
* reasonCode ^short = "Coded reason for use"
[r4-end]
[r5-init]
* medication only CodeableReference(MedicationEuCore)
* medication from $medication-uv-ips (example) 
* reason.concept ^short = "Coded reason for use"
* adherence.code ^short = "Type of adherence."
[r5-end]
 



