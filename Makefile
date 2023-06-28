.PHONY: check create group policy

check: policy.bicep
	@az bicep build --outfile /dev/null -f $^

group:
	@echo "using resource group $${GROUP:?}"

policy:
	@echo "using policy named $${POLICY_NAME:?}"

create: group policy
	@az deployment group create --resource-group $(GROUP) --template-file policy.bicep \
		--parameters policyName=$(POLICY_NAME)
