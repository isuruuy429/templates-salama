import ballerinax/health.fhir.r4;

final r4:ResourceAPIConfig apiConfig = {
    resourceType: "Coverage",
    profiles: [
        "https://hl7.org/fhir/us/core/STU6.1/SearchParameter-us-core-coverage-patient.html"
    ],
    defaultProfile: (),
    searchParameters: [
        {
            name: "identifier",
            active: true,
            information: {
                description: ""
            }
        },
        {
            name: "_id",
            active: true,
            information: {
                description: ""
            }
        },
        {
            name: "patient",
            active: true,
            information: {
                description: ""
            }
        }
    ],
    operations: [

    ],
    serverConfig: (),
    authzConfig: ()
};
