import VerifiedPolicyEvaluator.ReferenceEvaluator

namespace VerifiedPolicyEvaluator

/--
There exists a policy with the requested effect that applies to the request.

This is a logical proposition rather than an executable Boolean function.
It describes what it means for a matching policy to exist.
-/
def HasMatchingPolicy
    (effect : Effect)
    (policies : List Policy)
    (request : Request) :
    Prop :=
  ∃ policy ∈ policies,
    policy.effect = effect ∧
    policy.appliesTo request = true

/--
The declarative authorization specification.

A request is authorized exactly when:

1. at least one permit policy applies; and
2. no forbid policy applies.
-/
def Authorized
    (policies : List Policy)
    (request : Request) :
    Prop :=
  HasMatchingPolicy .permit policies request ∧
  ¬ HasMatchingPolicy .forbid policies request

/--
Boolean equality for policy effects agrees with propositional equality.

We prove this explicitly rather than relying implicitly on the generated
`BEq` instance.
-/
private theorem effect_beq_eq_true_iff
    (left right : Effect) :
    (left == right) = true ↔ left = right := by
  cases left <;> cases right <;> decide

/--
The executable matching search returns `true` exactly when the corresponding
declarative matching proposition holds.
-/
theorem hasMatchingEffect_eq_true_iff
    (effect : Effect)
    (policies : List Policy)
    (request : Request) :
    hasMatchingEffect effect policies request = true ↔
      HasMatchingPolicy effect policies request := by
  induction policies with
  | nil =>
      simp [hasMatchingEffect, HasMatchingPolicy]

  | cons policy rest inductionHypothesis =>
      simp [
        hasMatchingEffect,
        HasMatchingPolicy,
        effect_beq_eq_true_iff
      ]

/--
The executable matching search returns `false` exactly when no corresponding
matching policy exists.
-/
theorem hasMatchingEffect_eq_false_iff
    (effect : Effect)
    (policies : List Policy)
    (request : Request) :
    hasMatchingEffect effect policies request = false ↔
      ¬ HasMatchingPolicy effect policies request := by
  constructor

  · intro searchIsFalse matchingPolicyExists

    have searchIsTrue :
        hasMatchingEffect effect policies request = true :=
      (hasMatchingEffect_eq_true_iff effect policies request).2
        matchingPolicyExists

    simp [searchIsFalse] at searchIsTrue

  · intro noMatchingPolicy

    cases searchResult :
        hasMatchingEffect effect policies request with

    | false =>
        rfl

    | true =>
        exact False.elim (
          noMatchingPolicy (
            (hasMatchingEffect_eq_true_iff effect policies request).1
              searchResult
          )
        )

/--
The reference evaluator is correct with respect to the declarative
authorization specification.

This theorem establishes both directions:

* Soundness: every request approved by the evaluator is authorized by the
  specification.
* Completeness: every request authorized by the specification is approved by
  the evaluator.
-/
theorem authorizeReference_correct
    (policies : List Policy)
    (request : Request) :
    authorizeReference policies request = .allow ↔
      Authorized policies request := by
  by_cases matchingForbid :
      HasMatchingPolicy .forbid policies request

  · have forbidSearchIsTrue :
        hasMatchingEffect .forbid policies request = true :=
      (hasMatchingEffect_eq_true_iff .forbid policies request).2
        matchingForbid

    simp [
      authorizeReference,
      forbidSearchIsTrue,
      Authorized,
      matchingForbid
    ]

  · have forbidSearchIsFalse :
        hasMatchingEffect .forbid policies request = false :=
      (hasMatchingEffect_eq_false_iff .forbid policies request).2
        matchingForbid

    by_cases matchingPermit :
        HasMatchingPolicy .permit policies request

    · have permitSearchIsTrue :
          hasMatchingEffect .permit policies request = true :=
        (hasMatchingEffect_eq_true_iff .permit policies request).2
          matchingPermit

      simp [
        authorizeReference,
        forbidSearchIsFalse,
        permitSearchIsTrue,
        Authorized,
        matchingPermit,
        matchingForbid
      ]

    · have permitSearchIsFalse :
          hasMatchingEffect .permit policies request = false :=
        (hasMatchingEffect_eq_false_iff .permit policies request).2
          matchingPermit

      simp [
        authorizeReference,
        forbidSearchIsFalse,
        permitSearchIsFalse,
        Authorized,
        matchingPermit,
        matchingForbid
      ]

end VerifiedPolicyEvaluator
