Profile: ProcedureEuCore
Parent: Procedure
// Parent: ProcedureUvIps
Id: procedure-eu-core
Title:    "Procedure (EU core) [WIP]"
Description: "This profile represents the constraints applied to the Procedure resource by this guide."

// * insert ImposeProfile ( $Procedure-uv-ips, 0 )  // Check if this is appropriate (see  support)

* extension contains $procedure-targetBodyStructure named bodySite 0..1
* extension[bodySite].valueReference only Reference(BodyStructureEuCore)

[r4-init]
* extension contains $procedure-recorded-r5 named recorded 0..1
* extension[recorded] ^short = "Date when the procedure was recorded"
[r4-end]

* identifier ^short = "Identifier for the procedure"

* text ^short = "Textual representation of the procedur"
 // textual representation of the procedure should be provided according to the EHN data set
* status
* code 1.. 
  * ^binding.description = "Codes describing the type of  Procedure"
  * ^definition = "Identification of the procedure or recording of \"absence of relevant procedures\" or of \"procedures unknown\"."
* code from $procedures-uv-ips (preferred) 

* subject only Reference(PatientEuCore)
* subject 1..1
// * subject.reference 1..1 Only for IPS ?

[r4-init]
* performed[x] 1..1
[r4-end]
[r5-init]
* occurrence[x] 1..1
[r5-end]
/* * performed[x].extension contains $data-absent-reason named data-absent-reason 0..1
* performed[x].extension[data-absent-reason] ^short = "performed[x] absence reason"
* performed[x].extension[data-absent-reason] ^definition = "Provides a reason why the performed is missing." */
* performer.actor only Reference(PractitionerRoleEuCore or PractitionerEuCore or Device or PatientEuCore or RelatedPerson or  OrganizationEuCore)
* performer.onBehalfOf only Reference(OrganizationEuCore)
[r5-init]
* reason only CodeableReference(ConditionEuCore or Observation or ProcedureEuCore or DiagnosticReport or DocumentReference)
  * ^short = "Why the procedure was performed"
[r5-end]
[r4-init]
* reasonCode ^short = "Why the procedure was performed (code)"
* reasonReference only Reference ( ConditionEuCore or Observation or ProcedureEuCore or DiagnosticReport or DocumentReference)
  * ^short = "Why the procedure was performed (details)"
[r4-end]

* outcome ^short = "Outcome of the procedure"
[r4-init]
* complication ^short = "Complications that occurred during the procedure (code)"
* complicationDetail only Reference(ConditionEuCore)
  * ^short = "Complications that occurred during the procedure (details)"
[r4-end]
[r5-init]
* complication only CodeableReference(ConditionEuCore)
[r5-end]

[r4-init]
* usedCode ^short = "Device used to perform the procedure (code)"
* usedReference only Reference( Device or MedicationEuCore or Substance) // Specialize if needed
[r4-end]
[r5-init]
* used ^short = "Device used to perform the procedure"
* used only CodeableReference( Device or MedicationEuCore or Substance or BiologicallyDerivedProduct) // Specialize if needed
[r5-end]

* focalDevice ^short = "Device implanted, removed or otherwise manipulated"
* focalDevice.manipulated only Reference ( Device ) // DeviceEuCore
* bodySite from SNOMEDCTBodyStructures (preferred)
* bodySite
  * ^definition = "Anatomical location which is the focus of the problem."
  * extension contains $bodySite-reference named bodySite 0..1
  * extension[bodySite].valueReference only Reference(BodyStructureEuCore)  

  //* extension contains LateralityQualifier named laterality 0..1
* note ^short = "Additional information about the procedure."