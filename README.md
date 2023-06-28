# Policy exclusions for Azure EasyAuth behind Azure WAF

As designed by Microsoft, the [Azure Web Application Firewall][waf] with the CRS 3.2 engine will block requests that form part of the OAuth flow used by the
[Azure App Service provided built-in authentication and authorization][easyauth].

This repository provides a bicep script to add exclusions to allow problematic rules for these requests.

Assuming `$GROUP` and `$POLICY_NAME` envvars for your deployment, apply these rules with:

    az deployment group create --resource-group $GROUP --template-file policy.bicep \
      --parameters policyName=$POLICY_NAME

Note this will override existing settings in the policy, not add to them. Other rules are likely to need exclusions for your application to function reliably.


## What the firewall blocks

Many of the rules used by the firewall attempt to detect broad classes of potentially dangerous requests, rather than specific known vulnerabilities. The challenge with this approach is the firewall can only look at each http request in isolation, without knowledge of how any api or application will interpret those requests. The more general the rule, the more likely it is to prevent legitimate requests.

With "anomaly scoring" the Azure WAF with newer rulesets attempts to mitigate this "false positives" problem by assigning a score to each rule, and blocking only if the total score for a request exceeds a set threshold. This is a heuristic that is difficult to tune - particularly as the content of requests will vary. An api could work most the time, and based entirely on variable user-supplied or arbitrarily encoded content, appear to randomly fail on some requests.


## Rules that require exclusions

For the easyauth authentication flow, there are 4 rules that will cause requests to be blocked and require policy applied. One matches any percent encoded data, which is part of the `'redir'` param of the callback request, and the other three match base64 encoded data in general, which are used for `'code'` and `'id_token'` in the callback request and the cookie fields `'AppServiceAuthSession'` and `'Nonce'` in subsequent requests.


### 920230

"Multiple URL Encoding Detected" (WARNING)

Implementation:

    Pattern match \%\w at ARGS.

This matches any percent sign with a following character, [%ile](https://en.wiktionary.org/wiki/%25ile) for example.


### 942430

"Restricted SQL Character Anomaly Detection (args): # of special characters exceeded (12)" (WARNING)

The [Microsoft rules documentation][rules] suggests disabling this rule entirely due to "Too many false positives" which is good advice.

Implementation:

    Pattern match ((?:[~!@#\$%\^&\*\(\)\-\+=\{\}\[\]\|:;"'´’‘`<>][^~!@#\$%\^&\*\(\)\-\+=\{\}\[\]\|:;"'´’‘`<>]*?){12}) at ARGS.

This will not match [things that might be SQL injection][xkcd-327] and will match very simple content:

    > re.test("Robert'; DROP TABLE Students;--")
    false
    > re.test("------------")
    true

Will always match on long enough base64 data as `-` is in the alphabet.


### 942440

"SQL Comment Sequence Detected" (CRITICAL)

The [Microsoft rules documentation][rules] mentions this can be replaced by MSTIC rule 99031002.

Implementation:

    Pattern match (?:/\*!?|\*/|[';]--|--[\s\r\n\v\f]|--[^-]*?-|[^&-]#.*?[\s\r\n\v\f]|;?\x00) at ARGS.

This matches simple sequences such as "-- " and " # " that are likely to appear in a wide variety of content.

Will always match against long enough base64 data as `--` followed by `-` can appear.


### 942450

"SQL Hex Encoding Identified" (CRITICAL)

Implementation:

    Pattern match (?i:(?:\A|[^\d])0x[a-f\d]{3,}) at REQUEST_COOKIES.

Will match valid base64 sequences like `X0X0fA` as well as other forms of hex encoded data such as used in html or css.


## Copying

The content of this repo is free software (and documentation), you may redistribute and modify it under the terms of the [GPLv3+](https://www.gnu.org/licenses/gpl-3.0.en.html#license-text) while the exclusion descriptions _within_ the bicep script I would consider to be non-creative and may be extracted and used as per public domain.



[waf]: https://learn.microsoft.com/en-us/azure/web-application-firewall/
[easyauth]: https://docs.microsoft.com/en-us/azure/app-service/app-service-authentication-overview
[xkcd-327]: https://xkcd.com/327/
[best]: https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/best-practices
[rules]: https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules
[exclusion]: https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-waf-configuration
