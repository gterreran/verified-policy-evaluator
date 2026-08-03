import VerifiedPolicyEvaluator.Expression

namespace VerifiedPolicyEvaluator

/--
An authorization policy.

The policy name is descriptive metadata and does not affect authorization.
A policy matches when its condition evaluates to `true` for a request.
-/
structure Policy where
  name : String
  effect : Effect
  condition : Expr
  deriving Repr, DecidableEq, BEq

namespace Policy

/-- Determine whether a policy applies to an authorization request. -/
def appliesTo (policy : Policy) (request : Request) : Bool :=
  policy.condition.evaluate request

end Policy

end VerifiedPolicyEvaluator
