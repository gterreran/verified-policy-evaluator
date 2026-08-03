import VerifiedPolicyEvaluator.Proofs.SecurityProperties

open VerifiedPolicyEvaluator

namespace VerifiedPolicyEvaluator.Tests

/-- Empty policy sets always deny requests. -/
example
    (request : Request) :
    authorizeReference [] request = .deny :=
  empty_policy_set_denies request

/-- Every approval has a matching permit as justification. -/
example
    (policies : List Policy)
    (request : Request)
    (approved :
      authorizeReference policies request = .allow) :
    HasMatchingPolicy .permit policies request :=
  allow_requires_matching_permit policies request approved

/-- Approval is impossible in the presence of a matching forbid. -/
example
    (policies : List Policy)
    (request : Request)
    (approved :
      authorizeReference policies request = .allow) :
    ¬ HasMatchingPolicy .forbid policies request :=
  allow_excludes_matching_forbid policies request approved

/-- A permit is sufficient when no forbid applies. -/
example
    (policies : List Policy)
    (request : Request)
    (matchingPermit :
      HasMatchingPolicy .permit policies request)
    (noMatchingForbid :
      ¬ HasMatchingPolicy .forbid policies request) :
    authorizeReference policies request = .allow :=
  matching_permit_without_forbid_allows
    policies
    request
    matchingPermit
    noMatchingForbid

/-- A matching forbid wins when both effects are present. -/
example
    (policies : List Policy)
    (request : Request)
    (matchingPermit :
      HasMatchingPolicy .permit policies request)
    (matchingForbid :
      HasMatchingPolicy .forbid policies request) :
    authorizeReference policies request = .deny :=
  forbid_overrides_permit
    policies
    request
    matchingPermit
    matchingForbid

end VerifiedPolicyEvaluator.Tests
