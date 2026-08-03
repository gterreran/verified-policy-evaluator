import VerifiedPolicyEvaluator.Semantics

namespace VerifiedPolicyEvaluator

/--
An empty policy set denies every authorization request.

This is the simplest form of the default-deny property.
-/
theorem empty_policy_set_denies
    (request : Request) :
    authorizeReference [] request = .deny := by
  simp [authorizeReference, hasMatchingEffect]

/--
An authorization decision of `allow` requires at least one matching permit
policy.
-/
theorem allow_requires_matching_permit
    (policies : List Policy)
    (request : Request)
    (approved :
      authorizeReference policies request = .allow) :
    HasMatchingPolicy .permit policies request :=
  ((authorizeReference_correct policies request).mp approved).1

/--
An authorization decision of `allow` guarantees that no forbid policy matches.
-/
theorem allow_excludes_matching_forbid
    (policies : List Policy)
    (request : Request)
    (approved :
      authorizeReference policies request = .allow) :
    ¬ HasMatchingPolicy .forbid policies request :=
  ((authorizeReference_correct policies request).mp approved).2

/--
A matching permit policy authorizes a request when no forbid policy matches.
-/
theorem matching_permit_without_forbid_allows
    (policies : List Policy)
    (request : Request)
    (matchingPermit :
      HasMatchingPolicy .permit policies request)
    (noMatchingForbid :
      ¬ HasMatchingPolicy .forbid policies request) :
    authorizeReference policies request = .allow :=
  (authorizeReference_correct policies request).mpr
    ⟨matchingPermit, noMatchingForbid⟩

/--
Any matching forbid policy causes denial, regardless of the remaining policies.
-/
theorem matching_forbid_denies
    (policies : List Policy)
    (request : Request)
    (matchingForbid :
      HasMatchingPolicy .forbid policies request) :
    authorizeReference policies request = .deny := by
  have forbidSearchIsTrue :
      hasMatchingEffect .forbid policies request = true :=
    (hasMatchingEffect_eq_true_iff .forbid policies request).2
      matchingForbid

  simp [authorizeReference, forbidSearchIsTrue]

/--
If no permit policy matches, the request is denied.

This is the general default-deny property: approval must be explicitly
justified by a matching permit.
-/
theorem no_matching_permit_denies
    (policies : List Policy)
    (request : Request)
    (noMatchingPermit :
      ¬ HasMatchingPolicy .permit policies request) :
    authorizeReference policies request = .deny := by
  by_cases matchingForbid :
      HasMatchingPolicy .forbid policies request

  · exact matching_forbid_denies
      policies
      request
      matchingForbid

  · have forbidSearchIsFalse :
        hasMatchingEffect .forbid policies request = false :=
      (hasMatchingEffect_eq_false_iff .forbid policies request).2
        matchingForbid

    have permitSearchIsFalse :
        hasMatchingEffect .permit policies request = false :=
      (hasMatchingEffect_eq_false_iff .permit policies request).2
        noMatchingPermit

    simp [
      authorizeReference,
      forbidSearchIsFalse,
      permitSearchIsFalse
    ]

/--
A matching forbid overrides a matching permit.

The matching permit is intentionally included in the assumptions to state the
conflicting-policy case explicitly.
-/
theorem forbid_overrides_permit
    (policies : List Policy)
    (request : Request)
    (_matchingPermit :
      HasMatchingPolicy .permit policies request)
    (matchingForbid :
      HasMatchingPolicy .forbid policies request) :
    authorizeReference policies request = .deny :=
  matching_forbid_denies policies request matchingForbid

end VerifiedPolicyEvaluator
