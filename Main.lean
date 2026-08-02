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

def financeReadCondition : Expr :=
  .allOf
    (.actionEq ⟨"read"⟩)
    (.allOf
      (.attributeEq ⟨"department"⟩ (.text "finance"))
      (.attributeEq ⟨"mfa"⟩ (.bool true)))

def main : IO Unit := do
  IO.println "Verified Policy Evaluator"
  IO.println s!"Request: {reprStr exampleRequest}"
  IO.println
    s!"Finance read condition matched: {
      financeReadCondition.evaluate exampleRequest
    }"
