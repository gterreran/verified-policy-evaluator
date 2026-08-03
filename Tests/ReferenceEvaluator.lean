import VerifiedPolicyEvaluator.ReferenceEvaluator

open VerifiedPolicyEvaluator

namespace VerifiedPolicyEvaluator.Tests

private def aliceRequest : Request :=
  {
    principal := ⟨"alice"⟩
    action := ⟨"read"⟩
    resource := ⟨"financial-report"⟩
    attributes :=
      [
        (⟨"mfa"⟩, .bool true),
        (⟨"department"⟩, .text "finance")
      ]
  }

private def bobRequest : Request :=
  {
    principal := ⟨"bob"⟩
    action := ⟨"read"⟩
    resource := ⟨"financial-report"⟩
    attributes :=
      [
        (⟨"mfa"⟩, .bool false),
        (⟨"department"⟩, .text "engineering")
      ]
  }

private def financeReadPermit : Policy :=
  {
    name := "permit-finance-read"
    effect := .permit
    condition :=
      .allOf
        (.actionEq ⟨"read"⟩)
        (.attributeEq ⟨"department"⟩ (.text "finance"))
  }

private def requireMfaForbid : Policy :=
  {
    name := "forbid-without-mfa"
    effect := .forbid
    condition :=
      .negate
        (.attributeEq ⟨"mfa"⟩ (.bool true))
  }

private def aliceForbid : Policy :=
  {
    name := "forbid-alice"
    effect := .forbid
    condition := .principalEq ⟨"alice"⟩
  }

private def bobPermit : Policy :=
  {
    name := "permit-bob"
    effect := .permit
    condition := .principalEq ⟨"bob"⟩
  }

/-- Empty policy sets deny access by default. -/
example :
    authorizeReference [] aliceRequest = .deny := by
  decide

/-- A matching permit approves the request. -/
example :
    authorizeReference [financeReadPermit] aliceRequest = .allow := by
  decide

/-- A nonmatching permit does not approve the request. -/
example :
    authorizeReference [financeReadPermit] bobRequest = .deny := by
  decide

/-- A matching forbid denies the request. -/
example :
    authorizeReference [requireMfaForbid] bobRequest = .deny := by
  decide

/-- A nonmatching forbid does not block a matching permit. -/
example :
    authorizeReference
      [requireMfaForbid, financeReadPermit]
      aliceRequest = .allow := by
  decide

/-- A matching forbid overrides a matching permit. -/
example :
    authorizeReference
      [financeReadPermit, aliceForbid]
      aliceRequest = .deny := by
  decide

/-- Forbid precedence does not depend on policy order. -/
example :
    authorizeReference
      [aliceForbid, financeReadPermit]
      aliceRequest = .deny := by
  decide

/-- A permit for a different principal does not authorize Alice. -/
example :
    authorizeReference [bobPermit] aliceRequest = .deny := by
  decide

end VerifiedPolicyEvaluator.Tests
