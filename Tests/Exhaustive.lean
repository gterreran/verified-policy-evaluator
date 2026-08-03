import Lean
import VerifiedPolicyEvaluator.Proofs.CompilerCorrectness
import VerifiedPolicyEvaluator.Proofs.OrderIndependence

open VerifiedPolicyEvaluator

namespace VerifiedPolicyEvaluator.Tests

private def principals : List Principal :=
  [
    ⟨"alice"⟩,
    ⟨"bob"⟩
  ]

private def actions : List Action :=
  [
    ⟨"read"⟩,
    ⟨"write"⟩
  ]

private def resources : List Resource :=
  [
    ⟨"public-document"⟩,
    ⟨"secret-document"⟩
  ]

private def mfaValues : List Bool :=
  [
    false,
    true
  ]

private def departments : List String :=
  [
    "finance",
    "engineering"
  ]

/--
A small, finite authorization domain used for exhaustive executable checks.

The domain contains 32 distinct requests:

* 2 principals;
* 2 actions;
* 2 resources;
* 2 MFA states;
* 2 departments.
-/
private def requests : List Request :=
  principals.flatMap fun principal =>
    actions.flatMap fun action =>
      resources.flatMap fun resource =>
        mfaValues.flatMap fun mfa =>
          departments.map fun department =>
            {
              principal := principal
              action := action
              resource := resource
              attributes :=
                [
                  (⟨"mfa"⟩, .bool mfa),
                  (⟨"department"⟩, .text department)
                ]
            }

private def permitAlice : Policy :=
  {
    name := "permit-alice"
    effect := .permit
    condition := .principalEq ⟨"alice"⟩
  }

private def permitPublicDocument : Policy :=
  {
    name := "permit-public-document"
    effect := .permit
    condition :=
      .resourceEq ⟨"public-document"⟩
  }

private def permitFinance : Policy :=
  {
    name := "permit-finance"
    effect := .permit
    condition :=
      .attributeEq
        ⟨"department"⟩
        (.text "finance")
  }

private def forbidBob : Policy :=
  {
    name := "forbid-bob"
    effect := .forbid
    condition := .principalEq ⟨"bob"⟩
  }

private def forbidWrite : Policy :=
  {
    name := "forbid-write"
    effect := .forbid
    condition := .actionEq ⟨"write"⟩
  }

private def forbidWithoutMfa : Policy :=
  {
    name := "forbid-without-mfa"
    effect := .forbid
    condition :=
      .negate
        (.attributeEq ⟨"mfa"⟩ (.bool true))
  }

private def basePolicies : List Policy :=
  [
    permitAlice,
    permitPublicDocument,
    permitFinance,
    forbidBob,
    forbidWrite,
    forbidWithoutMfa
  ]

/-- Return every subset of a list. -/
private def subsets {α : Type} :
    List α → List (List α)
  | [] =>
      [[]]

  | item :: rest =>
      let tailSubsets := subsets rest

      tailSubsets ++
        tailSubsets.map fun subset =>
          item :: subset

/--
All 64 policy sets formed from the six representative policies above.
-/
private def policySets : List (List Policy) :=
  subsets basePolicies

/--
Check the compiled and reference evaluators on every finite policy-set/request
combination.
-/
private def allEvaluatorsAgree : Bool :=
  policySets.all fun policies =>
    requests.all fun request =>
      authorizeCompiled
          (compilePolicies policies)
          request ==
        authorizeReference policies request

/--
Check that reversing every finite policy set leaves every decision unchanged.
-/
private def allReversalsAgree : Bool :=
  policySets.all fun policies =>
    requests.all fun request =>
      authorizeReference policies request ==
        authorizeReference policies.reverse request

/-
64 policy sets × 32 requests = 2,048 evaluator comparisons.
-/
#guard allEvaluatorsAgree

/-
An additional 2,048 checks exercise policy-order independence.
-/
#guard allReversalsAgree

end VerifiedPolicyEvaluator.Tests
