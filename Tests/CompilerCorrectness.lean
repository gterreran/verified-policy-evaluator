import VerifiedPolicyEvaluator.Proofs.CompilerCorrectness
import VerifiedPolicyEvaluator.Proofs.SecurityProperties

open VerifiedPolicyEvaluator

namespace VerifiedPolicyEvaluator.Tests

/--
Compilation preserves authorization for every policy list and request.
-/
example
    (policies : List Policy)
    (request : Request) :
    authorizeCompiled
        (compilePolicies policies)
        request =
      authorizeReference policies request :=
  compilation_preserves_authorization policies request

/--
Approval from the compiled evaluator implies authorization under the
declarative specification.
-/
example
    (policies : List Policy)
    (request : Request)
    (approved :
      authorizeCompiled
          (compilePolicies policies)
          request = .allow) :
    Authorized policies request :=
  (authorizeCompiled_correct policies request).mp approved

/--
Authorization under the declarative specification implies approval from the
compiled evaluator.
-/
example
    (policies : List Policy)
    (request : Request)
    (authorized :
      Authorized policies request) :
    authorizeCompiled
        (compilePolicies policies)
        request = .allow :=
  (authorizeCompiled_correct policies request).mpr authorized

/--
A compiled evaluator denial agrees with the reference evaluator even when
permit and forbid policies both match.
-/
example
    (policies : List Policy)
    (request : Request)
    (matchingPermit :
      HasMatchingPolicy .permit policies request)
    (matchingForbid :
      HasMatchingPolicy .forbid policies request) :
    authorizeCompiled
        (compilePolicies policies)
        request = .deny := by
  rw [compilation_preserves_authorization]

  exact forbid_overrides_permit
    policies
    request
    matchingPermit
    matchingForbid

end VerifiedPolicyEvaluator.Tests
