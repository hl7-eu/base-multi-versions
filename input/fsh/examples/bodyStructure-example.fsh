Instance: BodyStructureExample
InstanceOf: BodyStructureEu
Title: "BodyStructure Example"
Description: "Example of a BodyStructure resource conforming to the BodyStructure (EU) profile."
* id = "example-body-structure-eu"

[r4-init]
* extension[laterality].valueCodeableConcept = $sct#7771000	"Left"
* location = $sct#8205005 "Wrist"
* locationQualifier = $sct#351726001 "Below"
[r4-end]
[r5-init]
* includedStructure
  * laterality = $sct#7771000 "Left"
  * structure = $sct#8205005 "Wrist"
  * qualifier = $sct#351726001 "Below"
[r5-end]

* patient = Reference(PatientExample)
* morphology =  $sct#339008 "Blister"
