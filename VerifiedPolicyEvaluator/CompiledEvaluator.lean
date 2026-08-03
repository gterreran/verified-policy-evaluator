import VerifiedPolicyEvaluator.Compiler

namespace VerifiedPolicyEvaluator

/--
Determine whether at least one policy in an already selected collection
applies to a request.
-/
def hasApplicablePolicy
    (policies : List Policy)
    (request : Request) :
    Bool :=
  policies.any fun policy =>
    policy.appliesTo request

/--
Evaluate an authorization request against a compiled policy set.

The decision rules are identical to the reference evaluator:

1. A matching forbid causes denial.
2. Otherwise, a matching permit causes approval.
3. Otherwise, access is denied by default.
-/
def authorizeCompiled
    (compiled : CompiledPolicySet)
    (request : Request) :
    Decision :=
  if hasApplicablePolicy compiled.forbids request then
    .deny
  else if hasApplicablePolicy compiled.permits request then
    .allow
  else
    .deny

end VerifiedPolicyEvaluator
