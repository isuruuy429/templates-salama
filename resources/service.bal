import ballerina/http;
import ballerina/time;
import ballerinax/health.fhir.r4;
import ballerinax/health.fhirr4;
import ballerinax/health.fhir.r4.international401;
import ballerinax/health.fhir.r4.parser as fhirParser;

# Generic type to wrap all implemented profiles.
# Add required profile types here.
public type Patient international401:Patient;

public type ExplanationOfBenefit international401:ExplanationOfBenefit;

public type Coverage international401:Coverage;

# initialize source system endpoint here

# A service representing a network-accessible API
# bound to port `9090`.
service / on new fhirr4:Listener(9090, apiConfig) {

    isolated resource function get fhir/r4/Patient/[string id](r4:FHIRContext fhirContext) returns Patient|r4:OperationOutcome|r4:FHIRError|error {
        lock {
            foreach json val in data {
                map<json> fhirResource = check val.ensureType();
                if (fhirResource.resourceType == "Patient" && fhirResource.id == id) {
                    Patient patient = check fhirParser:parse(fhirResource).ensureType();
                    return patient.clone();
                }
            }
        }
        return r4:createFHIRError("Not found", r4:ERROR, r4:INFORMATIONAL, httpStatusCode = http:STATUS_NOT_FOUND);
    }

    isolated resource function get fhir/r4/Patient(r4:FHIRContext fhirContext) returns r4:Bundle|r4:OperationOutcome|r4:FHIRError|error {
        lock {
            r4:StringSearchParameter[] queryParams = check fhirContext.getStringSearchParameter("family") ?: [];
            string family = check queryParams[0].value.ensureType();
            r4:Bundle bundle = {identifier: {system: ""}, 'type: "searchset", entry: []};
            r4:BundleEntry bundleEntry = {};
            int count = 0;
            json[] name = [];
            map<json> nameObject = {};
            foreach json val in data {
                map<json> fhirResource = check val.ensureType();
                if fhirResource.hasKey("name") {
                    name = check fhirResource.name.ensureType();
                    nameObject = <map<json>>name[0];
                    string familyName = (check nameObject.family).toString();
                    if (fhirResource.resourceType == "Patient" && familyName.equalsIgnoreCaseAscii(family)) {
                        bundleEntry = {fullUrl: "", 'resource: fhirResource};
                        bundle.entry[count] = bundleEntry;
                        count += 1;
                    }
                }
            }
            if bundle.entry != [] {
                return bundle.clone();
            }
        }
        return r4:createFHIRError("Not found", r4:ERROR, r4:INFORMATIONAL, httpStatusCode = http:STATUS_NOT_FOUND);
    }

    isolated resource function get fhir/r4/ExplanationOfBenefit(r4:FHIRContext fhirContext) returns r4:Bundle|r4:OperationOutcome|r4:FHIRError|error {
        lock {
            r4:ReferenceSearchParameter[] patientParams = check fhirContext.getReferenceSearchParameter("patient") ?: [];
            string patient = check patientParams[0].id.ensureType();
            r4:DateSearchParameter[]? createdDate = check fhirContext.getDateSearchParameter("created");
            string prefix = createdDate != () ? createdDate[0].prefix.toString() : "";
            time:Utc utc1 = [];
            if createdDate is r4:DateSearchParameter[] {
                time:Civil & readonly value = createdDate[0].value;
                utc1 = check time:utcFromCivil(value);
            }
            time:Utc utc2 = [];
            string date = "";
            r4:Bundle bundle = {identifier: {system: ""}, 'type: "searchset", entry: []};
            r4:BundleEntry bundleEntry = {};
            int count = 0;
            foreach json val in data {
                map<json> fhirResource = check val.ensureType();
                if (fhirResource.resourceType == "ExplanationOfBenefit" && fhirResource.patient == patient) {
                    date = (check fhirResource.created).toString() + "T00:00:00.00Z";
                    utc2 = check time:utcFromString(date);
                    if ((prefix == "gt" || prefix == "") && <int>(time:utcDiffSeconds(utc2, utc1)) > 0) {
                        bundleEntry = {fullUrl: "", 'resource: fhirResource};
                        bundle.entry[count] = bundleEntry;
                        count += 1;
                    } else if ((prefix == "eq" || prefix == "") && <int>(time:utcDiffSeconds(utc2, utc1)) == 0) {
                        bundleEntry = {fullUrl: "", 'resource: fhirResource};
                        bundle.entry[count] = bundleEntry;
                        count += 1;
                    }
                }
            }
            if bundle.entry != [] {
                return bundle.clone();
            }
        }
        return r4:createFHIRError("Not found", r4:ERROR, r4:INFORMATIONAL, httpStatusCode = http:STATUS_NOT_FOUND);
    }

    isolated resource function get fhir/r4/Coverage(r4:FHIRContext fhirContext) returns r4:Bundle|r4:OperationOutcome|r4:FHIRError|error {
        lock {
            r4:ReferenceSearchParameter[] patientParams = check fhirContext.getReferenceSearchParameter("patient") ?: [];
            string patient = check patientParams[0].id.ensureType();
            r4:TokenSearchParameter[] idParams = check fhirContext.getTokenSearchParameter("_id") ?: [];
            string id = idParams != [] ? idParams[0].code.toString() : "";
            r4:Bundle bundle = {identifier: {system: ""}, 'type: "searchset", entry: []};
            r4:BundleEntry bundleEntry = {};
            int count = 0;
            foreach json val in data {
                map<json> fhirResource = check val.ensureType();
                if (fhirResource.resourceType == "Coverage" && (fhirResource.patient == patient) && ((id == "") || (fhirResource.id == id))) {
                    bundleEntry = {fullUrl: "", 'resource: fhirResource};
                    bundle.entry[count] = bundleEntry;
                    count += 1;
                }
            }
            if bundle.entry != [] {
                return bundle.clone();
            }
        }
        return r4:createFHIRError("Not found", r4:ERROR, r4:INFORMATIONAL, httpStatusCode = http:STATUS_NOT_FOUND);
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
        "created": "2023-08-16",
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
        "created": "2014-08-16",
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
        "created": "2013-08-16",
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
