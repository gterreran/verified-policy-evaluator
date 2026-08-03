import VerifiedPolicyEvaluator.Expression

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
    action := ⟨"write"⟩
    resource := ⟨"engineering-report"⟩
    attributes :=
      [
        (⟨"mfa"⟩, .bool false),
        (⟨"department"⟩, .text "engineering")
      ]
  }

private def financeReadCondition : Expr :=
  .allOf
    (.actionEq ⟨"read"⟩)
    (.allOf
      (.attributeEq ⟨"department"⟩ (.text "finance"))
      (.attributeEq ⟨"mfa"⟩ (.bool true)))

example :
    Expr.evaluate .always aliceRequest = true := by
  decide

example :
    Expr.evaluate .never aliceRequest = false := by
  decide

example :
    Expr.evaluate (.principalEq ⟨"alice"⟩) aliceRequest = true := by
  decide

example :
    Expr.evaluate (.principalEq ⟨"bob"⟩) aliceRequest = false := by
  decide

example :
    Expr.evaluate
      (.attributeEq ⟨"department"⟩ (.text "finance"))
      aliceRequest = true := by
  decide

example :
    Expr.evaluate
      (.attributeEq ⟨"missing"⟩ (.text "value"))
      aliceRequest = false := by
  decide

example :
    Expr.evaluate financeReadCondition aliceRequest = true := by
  decide

example :
    Expr.evaluate financeReadCondition bobRequest = false := by
  decide

example :
    Expr.evaluate
      (.anyOf
        (.principalEq ⟨"alice"⟩)
        (.principalEq ⟨"bob"⟩))
      bobRequest = true := by
  decide

example :
    Expr.evaluate
      (.negate (.attributeEq ⟨"mfa"⟩ (.bool true)))
      bobRequest = true := by
  decide

example :
    Expr.evaluate
      (.resourceEq ⟨"financial-report"⟩)
      aliceRequest = true := by
  decide

example :
    Expr.evaluate
      (.resourceEq ⟨"engineering-report"⟩)
      aliceRequest = false := by
  decide

end VerifiedPolicyEvaluator.Tests
