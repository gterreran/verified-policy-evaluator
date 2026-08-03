import VerifiedPolicyEvaluator.Policy

namespace VerifiedPolicyEvaluator

/--
A policy set organized by effect.

The compiled representation separates permit policies from forbid policies,
allowing the evaluator to search each category directly.
-/
structure CompiledPolicySet where
  permits : List Policy
  forbids : List Policy
  deriving Repr

/--
Compile a flat policy list into permit and forbid collections.

Every input policy is placed in the collection corresponding to its effect.
The relative order within each collection is preserved.
-/
def compilePolicies
    (policies : List Policy) :
    CompiledPolicySet :=
  {
    permits :=
      policies.filter fun policy =>
        policy.effect == .permit

    forbids :=
      policies.filter fun policy =>
        policy.effect == .forbid
  }

end VerifiedPolicyEvaluator
