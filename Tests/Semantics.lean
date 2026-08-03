import VerifiedPolicyEvaluator.Semantics

open VerifiedPolicyEvaluator

namespace VerifiedPolicyEvaluator.Tests

/--
An approval returned by the executable evaluator implies authorization under
the declarative specification.
-/
example
    (policies : List Policy)
    (request : Request)
    (approved :
      authorizeReference policies request = .allow) :
    Authorized policies request :=
  (authorizeReference_correct policies request).mp approved

/--
Authorization under the declarative specification implies approval by the
executable evaluator.
-/
example
    (policies : List Policy)
    (request : Request)
    (authorized :
      Authorized policies request) :
    authorizeReference policies request = .allow :=
  (authorizeReference_correct policies request).mpr authorized

/-- No request is authorized by an empty policy set. -/
example
    (request : Request) :
    ¬ Authorized [] request := by
  simp [Authorized, HasMatchingPolicy]

end VerifiedPolicyEvaluator.Tests
