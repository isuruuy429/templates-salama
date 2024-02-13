import ballerinax/health.fhir.r4;
final r4:ResourceAPIConfig apiConfig = {
    resourceType: "OperationOutcome",
    profiles: [
        "http://hl7.org/fhir/StructureDefinition/OperationOutcome"        
    ],
    defaultProfile: (),
    searchParameters: [],
    operations: [],
    serverConfig: (),
    authzConfig: ()
};