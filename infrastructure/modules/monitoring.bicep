@description('Location for the Log Analytics workspace')
param location string

@description('Name of the AML workspace for labeling resources.')
param workspaceName string

@description('Monthly budget limit in USD. 0 = skip creating a budget.')
param monthlyBudgetLimit int

@description('Full resource ID of the AML workspace (e.g. /subscriptions/0000/resourceGroups/rg1/providers/Microsoft.MachineLearningServices/workspaces/myAML).')
param amlWorkspaceId string

var logAnalyticsName = '${workspaceName}-logs'
var diagSettingsName = 'amlDiagSettings'

// 1) Log Analytics Workspace
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// 2) Existing AML Workspace by ID
//    This avoids "resource does not have name" errors. We do not specify `name:` or `scope:` in an existing resource, only `id:`.
resource existingWorkspace 'Microsoft.MachineLearningServices/workspaces@2023-04-01' existing = {
  name: amlWorkspaceId
}

// 3) Diagnostic Settings
resource amlDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagSettingsName
  // Ties the diag settings to the *existing* workspace
  scope: existingWorkspace
  // Bicep infers a dependency on `logAnalytics` from `workspaceId: logAnalytics.id`.
  // If you want an explicit dependsOn to quell warnings, uncomment:
  // dependsOn: [ logAnalytics ]
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        category: 'AmlWorkspaceLogs'
        enabled: true
      }
      {
        category: 'AmlStudioUsage'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// 4) OPTIONAL: Resource Group–Level Budget (if monthlyBudgetLimit > 0)
@description('Name of the budget resource.')
var budgetName = '${workspaceName}-MonthlyBudget'

// A static date range (1 year). If you get parsing issues, keep it as yyyy-mm-dd.
var budgetStartDate = '2023-10-01'
var budgetEndDate   = '2024-10-01'

resource budget 'Microsoft.Consumption/budgets@2022-10-01' = if (monthlyBudgetLimit > 0) {
  name: budgetName
  scope: resourceGroup()
  properties: {
    category: 'Cost'
    timeGrain: 'Monthly'
    amount: monthlyBudgetLimit
    timePeriod: {
      startDate: budgetStartDate
      endDate: budgetEndDate
    }
    notifications: {
      Alert80Percent: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 80
        thresholdType: 'Actual'
        contactEmails: [
          'admin@contoso.com'
        ]
      }
    }
  }
}

// Output the Log Analytics resource ID for reference
output logAnalyticsId string = logAnalytics.id
