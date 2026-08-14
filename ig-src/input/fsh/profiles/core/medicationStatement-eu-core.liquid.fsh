//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Profile:  MedicationStatementEuCore
Parent:   MedicationStatement
Id:       medicationStatement-eu-core
Title:    "MedicationStatement (EU core)"
Description: """This profile introduces essential constraints and extensions for the MedicationStatement resource that apply across multiple use cases."""
//-------------------------------------------------------------------------------------------

* insert SetFmmandStatusRule (2, trial-use)

* derivedFrom ^short = "The reference to the source of the statement"
* language ^short = "Language of the statement"
* note.text ^short = "Textual note about the statement"

* identifier 
  * ^short = "Medication Statement Identifier"
// * status ^short = "Current state of the dispensation"
* subject only Reference( PatientEuCore or Group)
* status ^short = "State of the medication"
{% if isR4 %}
// should be removed ?
* statusReason ^short = "Reason for the 'exception' statuses of the medication"
{% endif %}
* category ^short = "Type of intended use"
{% if isR4 %}
  * ^binding.extension[+].url = "http://hl7.org/fhir/tools/StructureDefinition/additional-binding"
  * ^binding.extension[=].extension[+].url =  #purpose
  * ^binding.extension[=].extension[=].valueCode =  #preferred
  * ^binding.extension[=].extension[+].url = #valueSet
  * ^binding.extension[=].extension[=].valueCanonical =  Canonical(MedicationIntendedUseEuVs)
  * ^binding.extension[=].extension[+].url = "documentation"
  * ^binding.extension[=].extension[=].valueMarkdown = "When category is used for describing the intended use of the medication (e.g. Prophylactic use)."
{% endif %}
{% if isR5 %}
  * ^binding.additional[+].purpose = #preferred
  * ^binding.additional[=].valueSet = Canonical(MedicationIntendedUseEuVs)
  * ^binding.additional[=].documentation = "When category is used for describing the intended use of the medication (e.g. Prophylactic use)."
/* Slice cannot be used in R4
* category insert SliceElement ( #value, $this )
* category contains intendedUse 0..*
* category[intendedUse] from medicationIntendedUseEuVs
*/
{% endif %}
* dosage ^short = "Details of how medication is/was taken or should be taken."
  * route //copy the additional binding from the ips
* effectivePeriod ^short = "Period when the medication is/was or should be used."
{% if isR4 %}
* medication[x] only CodeableConcept or Reference(MedicationEuCore)
* medication[x] from $medication-uv-ips (example)
* extension contains $medicationStatement-adherence-r5 named adherence 0..1
* extension[adherence].extension[code] ^short = "Type of adherence."
* reasonCode ^short = "Coded reason for use"
{% endif %}
{% if isR5 %}
* medication only CodeableReference(MedicationEuCore)
* medication from $medication-uv-ips (example) 
* reason.concept ^short = "Coded reason for use"
* adherence.code ^short = "Type of adherence."
{% endif %}

* informationSource only Reference( PatientEuCore or PractitionerEuCore or PractitionerRoleEuCore or OrganizationEuCore or RelatedPerson )
  
 



