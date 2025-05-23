Profile: PatientAnimalEu
Parent: Patient
Id: Patient-animal-eu
Title:    "Patient: Animal"
Description: """This profile defines how to represent an Animal as subject of care in FHIR for the purpose of this guide.
This is used to identify the species when a specimen is collected from an animal"""

* insert SetFmmandStatusRule ( 2, draft)
* extension contains $patient-animal named patient-animal 1..1
* extension[patient-animal].extension[species].valueCodeableConcept from SpeciesTypesEuVs (example)
* extension contains $recordedSexOrGender named recordedSexOrGender 0..1
* extension[recordedSexOrGender]

* telecom ..0
  * ^short = "Use contact.telecom"
  * ^comment = "Animals do not have phones, their contacts do. Contact.telecom should be used."
* maritalStatus ..0
