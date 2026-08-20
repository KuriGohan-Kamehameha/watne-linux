# Physarum Arc Expression Vector Roadmap

- **Date:** 2026-08-20
- **Polyad room:** `physarum-arc-expression-vector-20260820`
- **Execution owner:** CPCS
- **Review owner:** GPTPCS
- **Planning model:** evidence gates, not calendar promises

## Objective

Advance from an auditable digital sequence map to a scientifically supportable decision about whether a Physarum Arc expression construct merits experimental evaluation. Every phase has an explicit exit gate. A later phase cannot turn an unverified upstream assumption into fact.

The current design is a **digital hypothesis**:

`[M73459.1 actin promoter candidate] → [NM_018790.3 Arc CDS] → [M73460.1 actin 3′-region candidate]`

The pUC19 derivative is a sequence-resolved visualization and bacterial propagation record. It is not evidence of Physarum replication, selection, integration, transcription, RNA processing, protein production, or capsid formation.

## North-star claim boundary

Use **candidate Physarum Arc expression vector** only after all four foundations are supported:

1. the complete sequence and feature coordinates are deterministic and independently parseable;
2. the promoter and 3′ processing region have current Physarum locus and transcript evidence;
3. every host-function module in the complete vector has an auditable base-level sequence; and
4. staged biological evidence separately demonstrates RNA, protein, and assembly outcomes with appropriate controls.

Before that gate, use narrower terms: **digital cassette**, **candidate regulatory region**, or **sequence-resolved fallback map**.

## Roadmap at a glance

| Phase | State | Primary outcome | Exit gate |
|---|---|---|---|
| 0. Evidence bundle | Complete | Accession-pinned source records and checksums | Every retained source parses and checksum-verifies |
| 1. Digital map release | Complete | Linear cassette and circular fallback in GenBank, FASTA, SVG, HTML, and JSON | 86 tests, 51 validator gates, byte-identical rebuild, and ApE import/map evidence passed |
| 2. Native regulatory evidence | Next | Modern locus and transcript-processing evidence for both Physarum flanks | Each flank receives an evidence-qualified disposition |
| 3. Complete Physarum vector architecture | Blocked on public sequence | Sequence-resolved host vector/backbone and provenance | No inferred bases; every functional module is traceable |
| 4. Host-compatibility assessment | After 2–3 | Translation and RNA-processing risk report without mutating the reference cassette | Every material incompatibility has a disposition |
| 5. Experimental-readiness dossier | Conditional | Governance, controls, measurements, and stop criteria | Independent scientific and biosafety review approves a bounded study |
| 6. Staged expression validation | Conditional | Separate evidence for transcript, protein, and localization | Predeclared controls pass; ambiguous results do not advance |
| 7. Arc assembly/function evaluation | Conditional | Assembly evidence distinct from expression | Orthogonal assembly evidence; no inference from abundance alone |
| 8. Release and maintenance | Continuous | Versioned records, decisions, negative results, and reproducible rebuilds | Every claim points to an immutable artifact or recorded experiment |

## Phase 0 — Evidence bundle

**Status:** complete.

Completed evidence:

- mouse Arc records `NM_018790.3` and `NP_061260.1` are accession- and checksum-pinned;
- the exact 1,191-nt Arc CDS retains its native terminal stop codon;
- `GCA_000413255.3` assembly metadata is retained;
- historical Physarum actin flanks `M73459.1` and `M73460.1` are retained;
- `M73459.1` has an explicit promoter annotation;
- `M73460.1` is annotated only as a 3′ UTR, not a terminator; and
- exact full-length searches did not place either historical flank in the LU352 assembly.

## Phase 1 — Digital map release

**Status:** complete. The release passed 86 automated tests, 51 executable validator gates, a byte-identical clean rebuild, immutable source-digest anchors, and independent ApE 3.1.10 import/map inspection.

Required release:

- a linear 2,879-bp cassette with features at `1..1049`, `1050..2240`, and `2241..2879`;
- a circular 5,565-bp fallback defined exactly as `M77789.2[1..270] + cassette + M77789.2[271..2686]`;
- annotated GenBank and FASTA for both records;
- deterministic linear and circular SVG maps;
- a self-contained HTML report;
- a machine-readable manifest and generated-artifact checksums;
- reproducible build, tests, validator, and CPCS verification report; and
- independent import into the free ApE plasmid editor.

The exit gate requires exact source equality, exact lengths, no junction padding, Arc translation equality to `NP_061260.1`, GenBank round-trip preservation, a byte-identical rebuild, correct linear/circular display, and caveats visible in every presentation layer.

Any source mismatch stops release. The circular record must not be called `pTB38`, a shuttle vector, or a validated Physarum vector.

## Phase 2 — Native regulatory evidence

**Status:** next; parallel with vector-sequence recovery.

Work packages:

1. Align both historical flank records to `GCA_000413255.3` using methods tolerant of strain divergence and fragmented assembly. Record coverage, identity, orientation, scaffold, ambiguity, and locus context.
2. Reconcile the historical `ardC` locus with current organism and assembly nomenclature. Distinguish promoter evidence from replication-origin evidence.
3. Seek direct evidence for transcription start, 3′ cleavage, and polyadenylation. A transcribed 3′ UTR is not automatically a termination signal.
4. Determine whether the source actin locus is active in the intended Physarum life stage and cell state.

Each flank exits as **supported for candidate use**, **supported only in a different strain/stage**, **ambiguous**, or **unsupported**. The 3′ region cannot be promoted to **terminator** without direct processing evidence.

## Phase 3 — Complete Physarum vector architecture

**Status:** blocked until a complete host-functional sequence is available.

Preferred path:

- recover an authoritative sequence for `pTB38`, `pTB41`, `pXM1`, or `pXM2` from a repository, supplement, archive, or author-provided record;
- verify it against published topology and feature order; and
- preserve whole-record provenance and redistribution terms.

Fallback path:

- create a separately versioned design only if every host-functional module has a base-level source sequence, explicit role, evidence-qualified Physarum function, known orientation/junction, and future verification assay.

The exit gate is a complete circular sequence with no inferred or diagram-derived bases. Bacterial propagation functions remain explicitly distinct from Physarum expression, selection, integration, or replication functions.

## Phase 4 — Host-compatibility assessment

**Status:** after regulatory and vector contexts are defined.

Assess:

- Physarum codon usage and GC context for the exact mouse Arc CDS;
- candidate cryptic splice sites, premature polyadenylation motifs, repeats, and RNA-processing risks;
- translation-initiation context at the promoter/CDS boundary;
- transcript surveillance or instability risk; and
- expected Arc localization, folding, and post-translational context in Physarum.

The accession-faithful cassette remains immutable. Any host-adapted version receives a new identifier, complete nucleotide diff, residue-equivalence report, rationale for every change, and separate validation.

## Phase 5 — Experimental-readiness dossier

**Status:** conditional planning, not a wet-lab protocol.

The dossier must define falsifiable hypotheses, host/life-stage rationale, construct provenance, institutional biosafety review, controls appropriate to each measurement, separate RNA/protein/localization/assembly endpoints, predeclared acceptance thresholds, replication rationale, sequence-confirmation chain of custody, stop criteria, and negative-result publication.

The exit gate is the ability to distinguish promoter failure, RNA-processing failure, translation failure, protein instability, and assembly failure. A reporter signal alone is insufficient.

## Phase 6 — Staged expression validation

**Status:** conditional on readiness approval.

Stage order:

1. validate the regulatory architecture with a benign reporter;
2. confirm transcript boundaries and abundance independently of reporter output;
3. evaluate the Arc coding construct for RNA and protein production; and
4. evaluate localization and cellular impact.

Each stage ends in a go, revise, or stop decision. Evidence at one molecular layer is not silently substituted for another.

## Phase 7 — Arc assembly and function

**Status:** conditional and separate from expression validation.

Questions:

- Does expressed Arc form expected higher-order assemblies?
- Are particle-like observations Arc-dependent rather than generic aggregates or vesicles?
- Is nucleic-acid association specific and reproducible?
- Does assembly depend on host context, expression level, or construct version?

The exit gate requires at least two orthogonal lines of evidence for Arc-specific assembly. Abundance, puncta, sedimentation, or morphology alone is insufficient.

## Phase 8 — Release and maintenance

**Status:** continuous.

Each release should contain immutable source/construct accessions, GenBank, FASTA, maps, manifest, checksums, build software, validator, viewer record, regulatory-evidence matrix, vector provenance dossier, compatibility report, and a decision log including negative/null results.

Any nucleotide change creates a new construct version. Changed interpretation updates evidence status without rewriting the original sequence record.

## Parallel workstreams

- **Sequence and provenance:** immutable records, checksums, accession drift, deterministic build, release packaging.
- **Physarum regulatory biology:** locus placement, promoter evidence, 3′ processing, stage expression, alternative native elements.
- **Vector architecture:** historical-vector recovery, complete module sequences, selection/integration/replication evidence.
- **Host compatibility:** coding context, RNA processing, translation, protein context, versioned redesign.
- **Validation and governance:** controls, measurements, stop criteria, biosafety, data integrity, claim language.

## Critical path

```text
Phase 1 digital release
  ├─> Phase 2 regulatory evidence ─┐
  └─> Phase 3 complete vector ─────┼─> Phase 4 compatibility
                                   └─> Phase 5 readiness
                                         └─> Phase 6 expression
                                               └─> Phase 7 assembly
                                                     └─> Phase 8 release
```

Phases 2 and 3 should proceed in parallel. Experimental readiness cannot bypass either.

## Risk register

| Risk | Severity | Required disposition |
|---|---:|---|
| `M73460.1` is not a confirmed terminator | High | Obtain processing evidence or replace it |
| Historical flanks do not exactly match LU352 | High | Alignment plus locus/transcript reconciliation |
| pUC19 has no demonstrated Physarum host function | High | Treat as visualization/bacterial backbone only |
| No complete public pTB38-family sequence found | High | Recover an authoritative record or design a separately versioned full vector |
| Arc CDS may be processed or translated differently in Physarum | High | Compatibility analysis followed by staged measurements |
| Life-stage expression may differ from the assumed constitutive state | Medium–High | Obtain stage-specific evidence before readiness |
| Expression may not produce Arc-specific assemblies | High | Require a separate orthogonal assembly phase |
| Source accessions or annotations may change | Medium | Version-pinned retrieval and checksum monitoring |
| Reporter success may be overgeneralized to Arc | High | Enforce separate RNA, protein, and assembly gates |

## Immediate next actions

1. Open two bounded parallel research packets:
   - reconcile `M73459.1` and `M73460.1` against current Physarum resources;
   - search repositories, supplements, and author archives for a complete pTB38-family sequence.
2. Do not begin host adaptation or experimental planning until those packets report their evidence and uncertainties.
