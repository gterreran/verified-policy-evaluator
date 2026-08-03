import VerifiedPolicyEvaluator.CompiledEvaluator
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
        (.attributeEq
          ⟨"department"⟩
          (.text "finance"))
  }

private def bobPermit : Policy :=
  {
    name := "permit-bob"
    effect := .permit
    condition :=
      .principalEq ⟨"bob"⟩
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
    condition :=
      .principalEq ⟨"alice"⟩
  }

private def examplePolicies : List Policy :=
  [
    financeReadPermit,
    requireMfaForbid,
    bobPermit,
    aliceForbid
  ]

private def compiledPolicies : CompiledPolicySet :=
  compilePolicies examplePolicies

/-- Compilation places permit policies in the permit collection. -/
example :
    compiledPolicies.permits =
      [financeReadPermit, bobPermit] := by
  decide

/-- Compilation places forbid policies in the forbid collection. -/
example :
    compiledPolicies.forbids =
      [requireMfaForbid, aliceForbid] := by
  decide

/-- Empty compiled policy sets deny by default. -/
example :
    authorizeCompiled
      (compilePolicies [])
      aliceRequest = .deny := by
  decide

/-- A matching compiled permit allows a request. -/
example :
    authorizeCompiled
      (compilePolicies [financeReadPermit])
      aliceRequest = .allow := by
  decide

/-- A matching compiled forbid causes denial. -/
example :
    authorizeCompiled
      (compilePolicies
        [financeReadPermit, aliceForbid])
      aliceRequest = .deny := by
  decide

/-- A missing permit results in denial. -/
example :
    authorizeCompiled
      (compilePolicies [financeReadPermit])
      bobRequest = .deny := by
  decide

/--
The two implementations agree on this representative policy set and request.
-/
example :
    authorizeCompiled
        (compilePolicies examplePolicies)
        aliceRequest =
      authorizeReference
        examplePolicies
        aliceRequest := by
  decide

/--
The implementations also agree on a request denied because of missing MFA.
-/
example :
    authorizeCompiled
        (compilePolicies examplePolicies)
        bobRequest =
      authorizeReference
        examplePolicies
        bobRequest := by
  decide

end VerifiedPolicyEvaluator.Tests
