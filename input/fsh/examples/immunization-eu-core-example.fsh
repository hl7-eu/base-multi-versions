Instance: ImmunizationEuCoreExample
InstanceOf: ImmunizationEuCore
Title: "Immunization Example"
Description: "Example of an Immunization resource conforming to the Immunization (EU Core) profile."

* id = "immunization-eu-core-example"
* status = #completed
* vaccineCode = $sct#1119349007 "SARS-CoV-2 mRNA vaccine"
* patient = Reference(PatientExample)
* occurrenceDateTime = "2024-10-05"
* occurrenceDateTime.extension[periodOfLife].valueCodeableConcept = $sct#41847000 "Adulthood"
* lotNumber = "CVD2024B04"
[r4-init]
* manufacturer
[r4-end]
[r5-init]
* manufacturer.reference
[r5-end]
  * display = "Example Vaccine Manufacturer"


* site = $sct#368208006 "Left upper arm structure"
* route = $sct#78421000 "Intramuscular route"
* location = Reference(LocationExample)
* primarySource = true
* performer[administeringCentreOrHp].function = $v2-0443#AP "Administering Provider"
* performer[administeringCentreOrHp].actor = Reference(PractitionerRoleEuCoreExample)
[r4-init]
* reasonCode = $sct#840539006 "Disease caused by severe acute respiratory syndrome coronavirus 2 (disorder)"
[r4-end]
[r5-init]
* reason[+].concept = $sct#840539006 "Disease caused by severe acute respiratory syndrome coronavirus 2 (disorder)"
[r5-end]
* protocolApplied[0].targetDisease = $sct#840539006 "COVID-19"
[r4-init]
* protocolApplied[0].doseNumberPositiveInt = 2
* protocolApplied[0].seriesDosesPositiveInt = 2
[r4-end]
[r5-init]
* protocolApplied[0].doseNumber = "2"
* protocolApplied[0].seriesDoses = "2"
[r5-end]
