import VerifiedPolicyEvaluator.CompiledEvaluator
import VerifiedPolicyEvaluator.Semantics

namespace VerifiedPolicyEvaluator

/--
Searching the policies selected by an effect filter is equivalent to searching
the original policy list for both that effect and applicability.
-/
theorem hasApplicablePolicy_filter_effect
    (effect : Effect)
    (policies : List Policy)
    (request : Request) :
    hasApplicablePolicy
        (policies.filter fun policy =>
          policy.effect == effect)
        request =
      hasMatchingEffect effect policies request := by
  induction policies with
  | nil =>
      rfl

  | cons policy rest inductionHypothesis =>
      cases effectMatches :
          policy.effect == effect <;>
        simp [
          effectMatches,
          hasApplicablePolicy,
          hasMatchingEffect,
        ]

/--
Searching the compiled permit collection is equivalent to searching the
original policy list for matching permit policies.
-/
theorem compiled_permit_search_eq
    (policies : List Policy)
    (request : Request) :
    hasApplicablePolicy
        (compilePolicies policies).permits
        request =
      hasMatchingEffect .permit policies request := by
  simpa [compilePolicies] using
    hasApplicablePolicy_filter_effect
      .permit
      policies
      request

/--
Searching the compiled forbid collection is equivalent to searching the
original policy list for matching forbid policies.
-/
theorem compiled_forbid_search_eq
    (policies : List Policy)
    (request : Request) :
    hasApplicablePolicy
        (compilePolicies policies).forbids
        request =
      hasMatchingEffect .forbid policies request := by
  simpa [compilePolicies] using
    hasApplicablePolicy_filter_effect
      .forbid
      policies
      request

/--
Compiling a policy list preserves its authorization behavior.

For every policy list and every request, the compiled evaluator produces
exactly the same decision as the reference evaluator.
-/
theorem compilation_preserves_authorization
    (policies : List Policy)
    (request : Request) :
    authorizeCompiled
        (compilePolicies policies)
        request =
      authorizeReference policies request := by
  simp only [
    authorizeCompiled,
    authorizeReference,
    compiled_forbid_search_eq,
    compiled_permit_search_eq
  ]

/--
The compiled evaluator is correct with respect to the original declarative
authorization specification.
-/
theorem authorizeCompiled_correct
    (policies : List Policy)
    (request : Request) :
    authorizeCompiled
        (compilePolicies policies)
        request = .allow ↔
      Authorized policies request := by
  rw [compilation_preserves_authorization]

  exact authorizeReference_correct policies request

end VerifiedPolicyEvaluator
