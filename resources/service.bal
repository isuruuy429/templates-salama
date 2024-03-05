import ballerina/http;
import ballerinax/health.fhir.r4.international401;
import ballerinax/health.fhir.r4.uscore501;
import ballerina/log;

# Generic type to wrap all implemented profiles.
# Add required profile types here.
public type Patient uscore501:USCorePatientProfile;

public type AllergyIntolerance uscore501:USCoreAllergyIntolerance;

public type CarePlan uscore501:USCoreCarePlanProfile;

public type CareTeam uscore501:USCoreCareTeam;

public type Condition uscore501:USCoreCondition;

public type Device uscore501:USCoreImplantableDeviceProfile;

public type DiagnosticReport uscore501:USCoreDiagnosticReportProfileNoteExchange|uscore501:USCoreDiagnosticReportProfileLaboratoryReporting;

public type DocumentReference uscore501:USCoreDocumentReferenceProfile;

public type Goal uscore501:USCoreGoalProfile;

public type Immunization uscore501:USCoreImmunizationProfile;

public type MedicationRequest uscore501:USCoreMedicationRequestProfile;

public type Observation uscore501:USCoreLaboratoryResultObservationProfile;

public type Procedure uscore501:USCoreProcedureProfile;

public type ExplanationOfBenefit international401:ExplanationOfBenefit;

public type Coverage international401:Coverage;

# initialize source system endpoint here

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    // Search for resources based on a set of criteria.
    isolated resource function get fhir/r4/Patient/[string id]() returns string|map<json>|error {
        lock {
            foreach json val in data {
                map<json> fhirResource = check val.ensureType();
                if (fhirResource.resourceType == "Patient" && fhirResource.id == id) {
                    return fhirResource.clone();
                }
            }
        }
        return error("No patient record found");
    }

    isolated resource function get fhir/r4/Patient(http:Request req) returns map<json>[]|error {
        string[] queryParamKeys = req.getQueryParams().keys();
        lock {
            map<json>[] patient = [];
            foreach json val in data {
                map<json> fhirResource = check val.ensureType();
                if fhirResource.hasKey("name") {
                    json[] name = check fhirResource.name.ensureType();
                    map<json> nameObject = <map<json>>name[0];
                    string family = (check nameObject.family).toString();
                    string queryParamValue = req.getQueryParamValue(queryParamKeys[0]).toString();
                    if (fhirResource.resourceType == "Patient" && family.equalsIgnoreCaseAscii(queryParamValue)) {
                        patient.push(fhirResource);
                    }
                }
            }
            if patient.length() > 0 {
                return patient.clone();
            }
        }
        return error("No patient record found");
    }

    // isolated resource function get fhir/r4/AllergyIntolerance(http:Request req) returns
    //     AllergyIntolerance {
    //     AllergyIntolerance allergyIntolerance = {
    //         resourceType: "AllergyIntolerance",
    //         id: "1",
    //         text: {
    //             "status": "generated",
    //             "div": ""
    //         },
    //         identifier: [],
    //         clinicalStatus: {
    //             "coding": [
    //                 {
    //                     "system": "http://terminology.hl7.org/CodeSystem/allergyintolerance-clinical",
    //                     "code": "active",
    //                     "display": "Active"
    //                 }
    //             ]
    //         },
    //         code: {},
    //         patient: {}
    //     };
    //     return allergyIntolerance;
    // }

    // isolated resource function get fhir/r4/CarePlan(http:Request req) returns CarePlan {
    //     CarePlan carePlan = {
    //         subject: {
    //             reference: "Patient/1",
    //             display: "Peter James Chalmers"
    //         },
    //         text: {
    //             div: "",
    //             status: "additional"
    //         },
    //         category: [],
    //         intent: "option",
    //         status: "unknown"
    //     };
    //     return carePlan;
    // }

    // isolated resource function get fhir/r4/CareTeam(http:Request req) returns CareTeam {
    //     CareTeam careTeam = {
    //         subject: {
    //             reference: "Patient/1",
    //             display: "Peter James Chalmers"
    //         },
    //         participant: []
    //     };
    //     return careTeam;
    // }

    // isolated resource function get fhir/r4/Condition(http:Request req) returns Condition {
    //     Condition condition = {
    //         code: {},
    //         subject: {
    //             reference: "Patient/1"
    //         },
    //         category: []
    //     };
    //     return condition;
    // }

    // isolated resource function get fhir/r4/Device(http:Request req) returns Device {
    //     Device device = {
    //         patient: {},
    //         'type: {}
    //     };
    //     return device;
    // }

    // isolated resource function get fhir/r4/DiagnosticReport(http:Request req) returns string {
    //     return "diagnosticReport";
    // }

    // isolated resource function get fhir/r4/DocumentReference(http:Request req) returns string {
    //     return "DocumentReference";
    // }

    // isolated resource function get fhir/r4/Goal(http:Request req) returns string {
    //     return "Goal";
    // }

    // isolated resource function get fhir/r4/Immunization(http:Request req) returns string {
    //     return "Immunization";
    // }

    // isolated resource function get fhir/r4/MedicationRequest(http:Request req) returns MedicationRequest {
    //     MedicationRequest medicationRequest = {
    //         requester: {},
    //         medicationReference: {},
    //         subject: {},
    //         medicationCodeableConcept: {},
    //         intent: "option",
    //         status: "unknown"
    //     };
    //     return medicationRequest;
    // }

    // isolated resource function get fhir/r4/Observation(http:Request req) returns Observation {
    //     Observation observation = {
    //         resourceType: "Observation",
    //         code: {
    //             "coding": [
    //                 {
    //                     "system": "http://loinc.org",
    //                     "code": "2708-6",
    //                     "display": "Body Weight"
    //                 }
    //             ]
    //         },
    //         subject: {},
    //         category: [],
    //         status: "preliminary"
    //     };
    //     return observation;
    // }

    // isolated resource function get fhir/r4/Procedure(http:Request req) returns string {
    //     return "procedure";
    // }

    isolated resource function get fhir/r4/ExplanationOfBenefit(string patient) returns json[]|error {
        log:printInfo(patient);
        lock {
            map<json>[] eob = [];

            foreach json val in data {
                map<json> fhirResource = check val.ensureType();
                if (fhirResource.resourceType == "ExplanationOfBenefit" && (fhirResource.patient == patient)) {
                    eob.push(fhirResource);
                }
            }
            if (eob.length() > 0) {
                return eob.clone();
            }
        }
        return error("No EOB record found");
    }

    isolated resource function get fhir/r4/Coverage(string patient, string _id) returns json[]|error {
        lock {
            map<json>[] coverage = [];
            foreach json val in data {
                map<json> fhirResource = check val.ensureType();
                if (fhirResource.resourceType == "Coverage" && (fhirResource.patient == patient) && ((_id=="\"\"")||(fhirResource.id==_id))) {
                    coverage.push(fhirResource);
                }
            }
            if (coverage.length() > 0) {
                return coverage.clone();
            }
        }
        return error("No coverage record found");
    }

}

isolated json[] data = [
    {
        "resourceType": "Patient",
        "id": "1",
        "active": true,
        "name": [
            {
                "family": "Doe",
                "given": ["John"],
                "use": "official",
                "prefix": ["Mr"]
            }
        ],
        "address": [
            {
                "line": ["652 S. Lantern Dr."],
                "city": "New York",
                "country": "United States",
                "postalCode": "10022",
                "type": "physical",
                "use": "home"
            }
        ],
        "identifier": [],
        "gender": "male"
    },

    {
        "resourceType": "Patient",
        "id": "2",
        "active": true,
        "name": [
            {
                "family": "Smith",
                "given": ["Jane", "A."],
                "use": "official"
            }
        ],
        "telecom": [
            {
                "system": "phone",
                "value": "+1 (555) 555-5555",
                "use": "home"
            },
            {
                "system": "email",
                "value": "jane.smith@example.com",
                "use": "work"
            }
        ],
        "birthDate": "1980-01-01",
        "gender": "female"
    },

    {
        "resourceType": "Patient",
        "id": "3",
        "active": true,
        "name": [
            {
                "family": "Lee",
                "given": ["David", "C."],
                "use": "official"
            }
        ],
        "address": [
            {
                "line": ["123 Main St.", "Apt. 202"],
                "city": "San Francisco",
                "country": "USA",
                "postalCode": "94105",
                "type": "physical",
                "use": "home"
            }
        ],
        "maritalStatus": {
            "coding": [
                {
                    "system": "http://terminology.hl7.org/CodeSystem/v3-MaritalStatus",
                    "code": "M",
                    "display": "Married"
                }
            ]
        },
        "communication": [
            {
                "language": {
                    "coding": [
                        {
                            "system": "http://terminology.hl7.org/CodeSystem/languages",
                            "code": "en",
                            "display": "English"
                        }
                    ]
                }
            }
        ]
    },

    {
        "resourceType": "ExplanationOfBenefit",
        "id": "1",
        "patient": "1",
        "serviceProvider": "Organization/2",
        "item": [
            {
                "service": {"display": "Office consultation"},
                "benefit": [
                    {"patientResponsibility": 10}
                ]
            }
        ]
    },

    {
        "resourceType": "ExplanationOfBenefit",
        "id": "2",
        "patient": "1",
        "diagnosis": [
            {"diagnosisCode": {"display": "Upper respiratory infection"}}
        ],
        "item": [
            {"service": {"display": "Office visit"}}
        ]
    },

    {
        "resourceType": "ExplanationOfBenefit",
        "id": "3",
        "patient": "2",
        "priorAuthorization": {
            "reference": "PriorAuthorization/123"
        },
        "item": [
            {
                "service": {"display": "MRI scan"},
                "benefit": [
                    {"allowed": 500}
                ]
            }
        ]
    },

    {
        "resourceType": "Coverage",
        "id": "1",
        "patient": "1",
        "type": {
            "coding": [
                {
                    "system": "http://terminology.hl7.org/CodeSystem/coverage-type",
                    "code": "indemnity",
                    "display": "Indemnity Insurance"
                }
            ]
        },
        "status": "active",
        "issued": "2023-01-01",
        "effectivePeriod": {
            "start": "2023-01-01",
            "end": "2024-12-31"
        },
        "payor": [
            {
                "reference": "Organization/2"
            }
        ],
        "beneficiary": {
            "reference": "Patient/1"
        },
        "class": {
            "coding": [
                {
                    "system": "http://terminology.hl7.org/CodeSystem/coverage-class",
                    "code": "platinum",
                    "display": "Platinum Plan"
                }
            ]
        }
    },

    {
        "resourceType": "Coverage",
        "id": "2",
        "patient": "1",
        "type": {
            "coding": [
                {
                    "system": "http://terminology.hl7.org/CodeSystem/coverage-type",
                    "code": "managed-care",
                    "display": "Managed Care"
                }
            ]
        },
        "status": "active",
        "issued": "2023-07-01",
        "effectivePeriod": {
            "start": "2023-07-01",
            "end": null
        },
        "holder": {
            "reference": "Patient/1"
        },
        "payor": [
            {
                "reference": "Organization/3"
            }
        ],
        "beneficiary": [
            {
                "reference": "Patient/1",
                "relationship": {
                    "coding": [
                        {
                            "system": "http://terminology.hl7.org/CodeSystem/v2-0006",
                            "code": "18",
                            "display": "Child"
                        }
                    ]
                }
            }
        ]
    },

    {
        "resourceType": "Coverage",
        "id": "3",
        "patient": "2",
        "type": {
            "coding": [
                {
                    "system": "http://terminology.hl7.org/CodeSystem/coverage-type",
                    "code": "vision",
                    "display": "Vision Insurance"
                }
            ]
        },
        "status": "active",
        "issued": "2024-01-01",
        "effectivePeriod": {
            "start": "2024-01-01",
            "end": "2024-12-31"
        },
        "holder": {
            "reference": "Patient/2"
        },
        "payor": [
            {
                "reference": "Organization/4"
            }
        ],
        "network": [
            {
                "reference": "Organization/5",
                "relationship": {
                    "coding": [
                        {
                            "system": "http://terminology.hl7.org/CodeSystem/plan-net-relationship",
                            "code": "in-network",
                            "display": "In-Network"
                        }
                    ]
                }
            }
        ]
    }
];
