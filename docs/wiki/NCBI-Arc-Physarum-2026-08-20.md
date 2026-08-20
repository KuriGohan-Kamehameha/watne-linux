# NCBI Arc + Physarum dataset (2026-08-20)

This page indexes the sequence bundle pulled from NCBI and validated on 2026-08-20.

Filed under [Gene Sequencing Data](Gene-Sequencing-Data.md). Terminology and construct names are defined in the [Gene Sequencing and Physarum Vector Glossary](Gene-Sequencing-Glossary.md).

The follow-on work is organized in the [Physarum Arc Expression Vector Roadmap](Physarum-Arc-Expression-Vector-Roadmap.md).

Files are stored in:

- `docs/wiki/data/gene-sequencing-data/ncbi-arc-physarum-2026-08-20/`

Primary references:

- Arc RefSeq mRNA (mouse): https://www.ncbi.nlm.nih.gov/nuccore/NM_018790.3
- Physarum assembly page: https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_000413255.3/

Included in this commit:

- Arc GenBank + mRNA + CDS + protein FASTA
- Physarum assembly dataset report JSON
- Historical Physarum actin 5' and 3' flank records (M73459.1, M73460.1)
- SHA-256 manifest and retrieval notes

## Construct-map progress

Last updated: **2026-08-20 21:30:47 UTC**

The Phase 1 digital map release was completed in durable polyad room
`physarum-arc-expression-vector-20260820`, labelled **Physarum Arc Expression
Vector**, with profile `triad_core_v1`. CPCS owns bounded execution and
verification; GPTPCS owns review.

The selected audit-first design produces both:

1. a 2,879-bp linear cassette — `M73459.1[1..1049] +
	 NM_018790.3[199..1389] + M73460.1[1..639]`; and
2. a 5,565-bp circular visualization record — public pUC19 `M77789.2[1..270] +
	 cassette + M77789.2[271..2686]`, placing the unchanged cassette at the SmaI
	 blunt cut between backbone bases 270 and 271.

Release evidence:

- authoritative NCBI `M77789.2`, the local pUC19 GenBank record, and the local
	pUC19 FASTA are identical across all 2,686 bases;
- the three source intervals are 1,049, 1,191, and 639 bases and byte-match the
	bundled FASTA extracts;
- the Arc CDS starts with `ATG`, ends with its native `TAG`, is divisible by
	three, and its 396 residues match local `NP_061260.1` after removing only the
	terminal stop marker;
- executable concatenation checks produced lengths of 2,879 and 5,565 bases,
	with the planned feature boundaries and no junction padding; and
- the design specification now records source provenance, immutable formulas,
	exact coordinates, acceptance gates, and the evidence boundary;
- 92 automated tests and 51 executable validator gates passed after an
	independent review/fix cycle, including adversarial mutation tests;
- a clean rebuild was byte-identical to the prior release tree;
- reviewed source digests are compiled as immutable trust anchors, including
	separate anchors for all three pUC19 provenance files;
- ApE 3.1.10 imported the 2,879-bp record as linear with four features and the
	5,565-bp record as circular with six features; and
- ApE generated a zero-circle linear canvas and a one-circle circular canvas.

After aggregate local memory was reported at 26 GB and rising, ApE was stopped
and subsequent clean build/test/validator work was moved to `branch-origin`.
That host retained 41 GiB available RAM; measured peak RSS was 107.7 MiB for the
build, 112.1 MiB for tests, and 107.2 MiB for validation. No gene-cauldron CT was
needed, so branch-prime's spooler and sentinels were left unchanged.

Primary release SHA-256 values:

- linear GenBank: `bbd212b2a675c5795b99f26bc7c28590c0721b0f3f7085db1cf5efef3707011c`
- circular GenBank: `8148bf09252d1d7932603a23224da998188b93ace5c7fd76a9bb23203c9c6e1b`
- manifest: `a6de1659d6e445fb23c8ddcdc1900b4902d857792baa9ab53ecc83ab533465b9`

No complete public base-level record for `pTB38`, `pTB41`, `pXM1`, or `pXM2`
has been located. Those constructs remain literature precedent only; no sequence
has been inferred for them.

Notes:

- The full extracted assembly package is large and was not committed to avoid repository bloat.
- Checksums and retrieval instructions are in `README.md` and `SHA256SUMS.txt` in the data folder.
