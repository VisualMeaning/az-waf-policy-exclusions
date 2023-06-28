// Copyright 2023 Visual Meaning Ltd
// This is free software licensed as GPLv3+ - see README.md#Copying for terms.

param policyName string
param location string = resourceGroup().location


resource wafPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2021-08-01' = {
  name: policyName
  location: location
  properties: {
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.2'
        }
      ]
      exclusions: [
        {
          matchVariable: 'RequestCookieValues'
          selectorMatchOperator: 'Equals'
          selector: 'AppServiceAuthSession'
          exclusionManagedRuleSets: [
            {
              ruleSetType: 'OWASP'
              ruleSetVersion: '3.2'
              ruleGroups: [
                {
                  ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
                  rules: [
                    {
                      ruleId: '942430'
                    }
                    {
                      ruleId: '942440'
                    }
                    {
                      ruleId: '942450'
                    }
                  ]
                }
              ]
            }
          ]
        }
        {
          matchVariable: 'RequestCookieValues'
          selectorMatchOperator: 'Equals'
          selector: 'Nonce'
          exclusionManagedRuleSets: [
            {
              ruleSetType: 'OWASP'
              ruleSetVersion: '3.2'
              ruleGroups: [
                {
                  ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
                  rules: [
                    {
                      ruleId: '942430'
                    }
                    {
                      ruleId: '942440'
                    }
                    {
                      ruleId: '942450'
                    }
                  ]
                }
              ]
            }
          ]
        }
        {
          matchVariable: 'RequestArgValues'
          selectorMatchOperator: 'Equals'
          selector: 'code'
          exclusionManagedRuleSets: [
            {
              ruleSetType: 'OWASP'
              ruleSetVersion: '3.2'
              ruleGroups: [
                {
                  ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
                  rules: [
                    {
                      ruleId: '942430'
                    }
                    {
                      ruleId: '942440'
                    }
                    {
                      ruleId: '942450'
                    }
                  ]
                }
              ]
            }
          ]
        }
        {
          matchVariable: 'RequestArgValues'
          selectorMatchOperator: 'Equals'
          selector: 'id_token'
          exclusionManagedRuleSets: [
            {
              ruleSetType: 'OWASP'
              ruleSetVersion: '3.2'
              ruleGroups: [
                {
                  ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
                  rules: [
                    {
                      ruleId: '942430'
                    }
                    {
                      ruleId: '942440'
                    }
                    {
                      ruleId: '942450'
                    }
                  ]
                }
              ]
            }
          ]
        }
        {
          matchVariable: 'RequestArgValues'
          selectorMatchOperator: 'Equals'
          selector: 'redir'
          exclusionManagedRuleSets: [
            {
              ruleSetType: 'OWASP'
              ruleSetVersion: '3.2'
              ruleGroups: [
                {
                  ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
                  rules: [
                    {
                      ruleId: '920230'
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  }
}
