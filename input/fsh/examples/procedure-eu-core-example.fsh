Instance: ProcedureEuCoreExample
InstanceOf: ProcedureEuCore
Title: "Procedure Example"
Description: "Example of a Procedure resource conforming to the Procedure (EU Core) profile."

* id = "procedure-eu-core-example"
* status = #completed
* code = $sct#80146002 "Appendectomy"
* subject = Reference(PatientExample)
[r4-init]
* performedDateTime = "2023-04-15"
[r4-end]
[r5-init]
* occurrenceDateTime = "2023-04-15"
[r5-end]
* performer.actor = Reference(PractitionerRoleEuCoreExample)
* bodySite = $sct#66754008 "Appendix structure"
* note.text = "Laparoscopic procedure with no complications."

