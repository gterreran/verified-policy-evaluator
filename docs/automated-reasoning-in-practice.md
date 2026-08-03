# From a Learning Project to Automated Reasoning in Practice

## Motivation

This project began as a personal exploration of Lean 4 and formal verification.

Most of my previous software work relied on conventional testing: execute code on representative inputs, inspect the results, and expand the test suite when new edge cases are discovered.

That approach is indispensable, but it leaves a natural question:

> What would it mean to verify an important property for every possible input rather than for a selected collection of examples?

I wanted to explore that question through a project that was small enough to finish but substantial enough to resemble a real software-design problem.

Authorization was a useful domain because even a miniature policy evaluator has meaningful requirements:

* access should be denied unless explicitly permitted;
* explicit prohibitions should take precedence;
* policy order should not alter the result;
* an optimization should not silently change authorization behavior.

These properties can be written precisely and connected directly to executable code.

## What Lean changes

In ordinary application development, a function may be accompanied by documentation and tests describing its intended behavior.

In this project, the intended behavior is also represented inside Lean as a proposition:

```lean
Authorized policies request
```

The evaluator and the specification are different definitions.

A theorem then connects them:

```lean
authorizeReference policies request = .allow ↔
  Authorized policies request
```

The proof is not an additional runtime check. Lean verifies during compilation that the theorem follows from the definitions and previously established results.

This changes the development workflow.

Instead of asking only:

> Which examples should be tested?

the project also asks:

> What exact statement should hold for every request and policy list?

Writing that statement is often one of the most valuable parts of the exercise.

## Specifications and implementations

The repository contains three levels of description:

```text
Declarative authorization predicate
              ↓
Simple reference evaluator
              ↓
Compiled evaluator
```

The reference evaluator is proved equivalent to the specification.

The compiled evaluator is proved equivalent to the reference evaluator.

This makes the compiler theorem a semantic-preservation result: the internal representation changes, but observable authorization decisions do not.

The pattern is broadly applicable beyond authorization:

* compilers preserving program meaning;
* optimized algorithms preserving reference behavior;
* protocol implementations satisfying state-machine specifications;
* data transformations preserving invariants;
* security checks enforcing access-control rules.

## Proofs and tests together

Formal verification does not eliminate the value of testing.

The repository includes concrete scenarios and exhaustive checks over a finite domain in addition to universal proofs.

The proofs establish claims about all model values. The executable checks make examples visible, exercise the surrounding code, and provide another way to detect mistakes when the project evolves.

This combination resembles a practical verification workflow more closely than treating proofs and tests as competing techniques.

## Inspiration from production systems

Public examples of automated reasoning being applied to production software helped motivate the project.

One particularly relevant example is the work surrounding the Cedar authorization language. Cedar illustrates how an authorization language can have:

* a precise semantic model;
* an executable implementation;
* stated security properties;
* formal analysis;
* differential and executable testing.

Verified Policy Evaluator does not implement Cedar and does not attempt to reproduce its language, performance, or verification infrastructure.

Instead, it explores several of the same foundational ideas on a deliberately smaller scale:

* represent policy conditions as a defined language;
* separate declarative semantics from executable evaluation;
* prove default-deny and forbid-precedence properties;
* prove that policy ordering does not influence decisions;
* prove that a compiled representation preserves behavior;
* retain executable tests alongside formal proofs.

AWS’s public work in automated reasoning is therefore an inspiration and a demonstration of where these ideas can lead—not the reason the repository exists and not a claim that this project is equivalent to a production verification effort.

## Lessons from the first version

Several lessons emerged while building the project.

### Precise definitions matter

Before proving an evaluator correct, authorization itself had to be defined independently.

Small design decisions became explicit:

* What happens when an attribute is missing?
* What happens when multiple forbids match?
* Does policy order matter?
* Can a permit alone authorize a request?
* How are duplicate attributes interpreted?

Formalization exposes ambiguity early.

### Simple implementations are valuable

The reference evaluator is not optimized, but its simplicity makes it useful.

It provides an implementation that is easy to compare with the declarative specification and a stable behavioral target for compiler transformations.

### Proofs benefit from intermediate lemmas

The main theorems depend on smaller bridges:

* Boolean equality agrees with propositional equality;
* executable search agrees with existential matching;
* permutation preserves matching-policy existence;
* effect filtering preserves search behavior.

The intermediate results make the final proofs shorter and give the repository a reusable proof API.

### Trusted assumptions should be documented

A machine-checked theorem can still be misunderstood if its scope is unclear.

The project verifies the core Lean model. It does not verify identity authentication, external input parsing, operating-system behavior, or whether a human wrote the correct policies.

Documenting these boundaries is part of presenting verification responsibly.

## Continuing the project

The initial version is deliberately complete rather than broad.

Future work could introduce a more meaningful indexing compiler, richer request data, policy validation, or explanatory decisions. Each extension would create new proof obligations and provide another opportunity to compare conventional software-engineering intuition with formal reasoning.

The main outcome of this version is not merely a set of finished theorems. It is experience with the full cycle:

```text
Informal requirement
        ↓
Formal definition
        ↓
Executable implementation
        ↓
Machine-checked property
        ↓
Alternative implementation
        ↓
Semantic-preservation proof
        ↓
Executable tests and CI
```

That cycle is the part of automated reasoning I wanted to understand through direct practice.

## Further reading

* [Cedar specification and formalization](https://github.com/cedar-policy/cedar-spec)
* [How Amazon Web Services uses formal methods](https://www.amazon.science/publications/how-amazon-web-services-uses-formal-methods)

