// Parameters
param location string = resourceGroup().location
param workflowName string
param workflowSource object

// Nested logic app
resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: workflowName
  location: location
  properties: {
    state: 'Enabled'
    definition: workflowSource.definition
    parameters: workflowSource.parameters
  }
}

output name string = logicApp.name
output id string = resourceId('Microsoft.Logic/workflows', logicApp.name)
