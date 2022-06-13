targetScope = 'subscription'
// Parameters
param prefix string
param suffix string = uniqueString(newGuid())
param location string = deployment().location

module group './resourceGroup.bicep' = {
  name: '${prefix}-${suffix}'
  params: {
    name: '${prefix}-${suffix}'
    location: location
  }
}

// nested logic app
module nestedLogicApp './logicApp.bicep' = {
  name: '${prefix}-nested-${suffix}'
  scope: resourceGroup(group.name)
  params: {
    workflowName: '${prefix}-nested-${suffix}'
    workflowSource: json(loadTextContent('../src/workflows/nested/workflow.json'))
    location: location
  }
}


// parent logic app
module parentLogicApp './logicApp.bicep' = {
  name: '${prefix}-parent-${suffix}'
  scope: resourceGroup(group.name)
  params: {
    workflowName: '${prefix}-parent-${suffix}'
    workflowSource: json(replace(replace(replace(loadTextContent('../src/workflows/parent/workflow.json'), '{subscriptionId}', subscription().id), '{resourceGroup}', group.outputs.name), '{workflowName}', nestedLogicApp.outputs.name))
    location: location
  }
  dependsOn: [
    nestedLogicApp
  ]
}
