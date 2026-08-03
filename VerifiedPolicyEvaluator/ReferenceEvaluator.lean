import VerifiedPolicyEvaluator.Policy

namespace VerifiedPolicyEvaluator

/--
Determine whether at least one policy with the requested effect matches.

This function scans the complete policy list and serves as part of the simple
reference implementation against which future evaluators will be compared.
-/
def hasMatchingEffect
    (effect : Effect)
    (policies : List Policy)
    (request : Request) :
    Bool :=
  policies.any fun policy =>
    policy.effect == effect && policy.appliesTo request

/--
Evaluate an authorization request against a list of policies.

The decision rules are:

1. A matching `forbid` policy causes denial.
2. Otherwise, a matching `permit` policy causes approval.
3. Otherwise, access is denied by default.
-/
def authorizeReference
    (policies : List Policy)
    (request : Request) :
    Decision :=
  if hasMatchingEffect .forbid policies request then
    .deny
  else if hasMatchingEffect .permit policies request then
    .allow
  else
    .deny

end VerifiedPolicyEvaluator
