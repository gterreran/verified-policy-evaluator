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

def main : IO Unit := do
  IO.println "Verified Policy Evaluator"
  IO.println s!"Example request: {reprStr exampleRequest}"
