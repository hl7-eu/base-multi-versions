Instance: ProcedureEuCoreExample
InstanceOf: ProcedureEuCore
Title: "Procedure Example"
Description: "Example of a Procedure resource conforming to the Procedure (EU Core) profile."

* id = "procedure-eu-core-example"
* status = #completed
* code = $sct#80146002 "Appendectomy"
* subject = Reference(PatientExample)
{% if isR4 %}
* performedDateTime = "2023-04-15"
{% endif %}
{% if isR5 %}
* occurrenceDateTime = "2023-04-15"
{% endif %}
* performer.actor = Reference(PractitionerRoleEuCoreExample)
* bodySite = $sct#66754008 "Appendix structure"
* note.text = "Laparoscopic procedure with no complications."

