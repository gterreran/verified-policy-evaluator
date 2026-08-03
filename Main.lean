import VerifiedPolicyEvaluator

open VerifiedPolicyEvaluator

def exampleRequest : Request :=
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

def financeReadPermit : Policy :=
  {
    name := "permit-finance-read"
    effect := .permit
    condition :=
      .allOf
        (.actionEq ⟨"read"⟩)
        (.attributeEq ⟨"department"⟩ (.text "finance"))
  }

def requireMfaForbid : Policy :=
  {
    name := "forbid-without-mfa"
    effect := .forbid
    condition :=
      .negate
        (.attributeEq ⟨"mfa"⟩ (.bool true))
  }

def examplePolicies : List Policy :=
  [
    financeReadPermit,
    requireMfaForbid
  ]

def main : IO Unit := do
  let decision := authorizeReference examplePolicies exampleRequest

  IO.println "Verified Policy Evaluator"
  IO.println s!"Request: {reprStr exampleRequest}"
  IO.println s!"Decision: {reprStr decision}"
