import VerifiedPolicyEvaluator.Proofs.OrderIndependence

open VerifiedPolicyEvaluator

namespace VerifiedPolicyEvaluator.Tests

private def aliceRequest : Request :=
  {
    principal := ⟨"alice"⟩
    action := ⟨"read"⟩
    resource := ⟨"financial-report"⟩
    attributes :=
      [
        (⟨"department"⟩, .text "finance")
      ]
  }

private def financeReadPermit : Policy :=
  {
    name := "permit-finance-read"
    effect := .permit
    condition :=
      .allOf
        (.actionEq ⟨"read"⟩)
        (.attributeEq
          ⟨"department"⟩
          (.text "finance"))
  }

private def aliceForbid : Policy :=
  {
    name := "forbid-alice"
    effect := .forbid
    condition :=
      .principalEq ⟨"alice"⟩
  }

/--
The generic theorem can be used for any two policy lists related by a
permutation.
-/
example
    (policiesLeft policiesRight : List Policy)
    (request : Request)
    (permutation :
      policiesLeft.Perm policiesRight) :
    authorizeReference policiesLeft request =
      authorizeReference policiesRight request :=
  authorizeReference_order_independent
    permutation
    request

/-- Swapping two conflicting policies does not affect the result. -/
example :
    authorizeReference
        [financeReadPermit, aliceForbid]
        aliceRequest =
      authorizeReference
        [aliceForbid, financeReadPermit]
        aliceRequest := by
  apply authorizeReference_order_independent

  exact List.Perm.swap
    aliceForbid
    financeReadPermit
    []

/-- Both orderings deny because the matching forbid takes precedence. -/
example :
    authorizeReference
      [financeReadPermit, aliceForbid]
      aliceRequest = .deny := by
  decide

example :
    authorizeReference
      [aliceForbid, financeReadPermit]
      aliceRequest = .deny := by
  decide

end VerifiedPolicyEvaluator.Tests
