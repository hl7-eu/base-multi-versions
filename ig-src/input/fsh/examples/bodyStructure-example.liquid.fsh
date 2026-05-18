Instance: BodyStructureExample
InstanceOf: BodyStructureEuCore
Title: "BodyStructure Example"
Description: "Example of a BodyStructure resource conforming to the BodyStructure (EU) profile."
* id = "example-body-structure-eu"

{% if isR4 %}
* extension[includedStructure].extension[structure].valueCodeableConcept = $sct#8205005 "Wrist"
* extension[includedStructure].extension[laterality].valueCodeableConcept = $sct#7771000 "Left"
* extension[includedStructure].extension[qualifier].valueCodeableConcept = $sct#351726001 "Below"
{% endif %}
{% if isR5 %}
* includedStructure
  * laterality = $sct#7771000 "Left"
  * structure = $sct#8205005 "Wrist"
  * qualifier = $sct#351726001 "Below"
{% endif %}

* patient = Reference(PatientExample)
* morphology =  $sct#339008 "Blister"
