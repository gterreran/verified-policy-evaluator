import VerifiedPolicyEvaluator.Proofs.SecurityProperties

namespace VerifiedPolicyEvaluator

/--
The existence of a matching policy is preserved when the policy list is
permuted.
-/
theorem hasMatchingPolicy_perm_iff
    {policiesLeft policiesRight : List Policy}
    (permutation : policiesLeft.Perm policiesRight)
    (effect : Effect)
    (request : Request) :
    HasMatchingPolicy effect policiesLeft request ↔
      HasMatchingPolicy effect policiesRight request := by
  constructor

  · rintro ⟨policy, policyInLeft, effectMatches, policyApplies⟩

    exact ⟨
      policy,
      permutation.mem_iff.mp policyInLeft,
      effectMatches,
      policyApplies
    ⟩

  · rintro ⟨policy, policyInRight, effectMatches, policyApplies⟩

    exact ⟨
      policy,
      permutation.mem_iff.mpr policyInRight,
      effectMatches,
      policyApplies
    ⟩

/--
Declarative authorization is preserved when the policy list is permuted.
-/
theorem authorized_perm_iff
    {policiesLeft policiesRight : List Policy}
    (permutation : policiesLeft.Perm policiesRight)
    (request : Request) :
    Authorized policiesLeft request ↔
      Authorized policiesRight request := by
  constructor

  · rintro ⟨matchingPermit, noMatchingForbid⟩

    constructor

    · exact
        (hasMatchingPolicy_perm_iff
          permutation
          .permit
          request).mp matchingPermit

    · intro matchingForbidRight

      apply noMatchingForbid

      exact
        (hasMatchingPolicy_perm_iff
          permutation
          .forbid
          request).mpr matchingForbidRight

  · rintro ⟨matchingPermit, noMatchingForbid⟩

    constructor

    · exact
        (hasMatchingPolicy_perm_iff
          permutation
          .permit
          request).mpr matchingPermit

    · intro matchingForbidLeft

      apply noMatchingForbid

      exact
        (hasMatchingPolicy_perm_iff
          permutation
          .forbid
          request).mp matchingForbidLeft

/--
Two decisions are equal when they agree on whether the result is `allow`.

This works because `Decision` has exactly two constructors.
-/
private theorem decision_eq_of_allow_iff
    (left right : Decision)
    (sameAllowStatus :
      (left = .allow ↔ right = .allow)) :
    left = right := by
  cases left <;> cases right <;> simp_all

/--
Reordering the same policies cannot change the result of the reference
authorization evaluator.
-/
theorem authorizeReference_order_independent
    {policiesLeft policiesRight : List Policy}
    (permutation : policiesLeft.Perm policiesRight)
    (request : Request) :
    authorizeReference policiesLeft request =
      authorizeReference policiesRight request := by
  apply decision_eq_of_allow_iff

  constructor

  · intro leftAllows

    have leftAuthorized :
        Authorized policiesLeft request :=
      (authorizeReference_correct
        policiesLeft
        request).mp leftAllows

    have rightAuthorized :
        Authorized policiesRight request :=
      (authorized_perm_iff
        permutation
        request).mp leftAuthorized

    exact
      (authorizeReference_correct
        policiesRight
        request).mpr rightAuthorized

  · intro rightAllows

    have rightAuthorized :
        Authorized policiesRight request :=
      (authorizeReference_correct
        policiesRight
        request).mp rightAllows

    have leftAuthorized :
        Authorized policiesLeft request :=
      (authorized_perm_iff
        permutation
        request).mpr rightAuthorized

    exact
      (authorizeReference_correct
        policiesLeft
        request).mpr leftAuthorized

end VerifiedPolicyEvaluator
