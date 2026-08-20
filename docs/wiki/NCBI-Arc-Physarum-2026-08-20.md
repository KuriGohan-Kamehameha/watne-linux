# NCBI Arc + Physarum dataset (2026-08-20)

This page indexes the sequence bundle pulled from NCBI and validated on 2026-08-20.

Filed under [Gene Sequencing Data](Gene-Sequencing-Data.md). Terminology and construct names are defined in the [Gene Sequencing and Physarum Vector Glossary](Gene-Sequencing-Glossary.md).

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

Last updated: **2026-08-20 17:37:27 UTC**

The follow-on digital map is being built in durable polyad room
`physarum-arc-expression-vector-20260820`, labelled **Physarum Arc Expression
Vector**, with profile `triad_core_v1`. CPCS owns bounded execution and
verification; GPTPCS owns review. The room remains `Running` at room sequence 4.

The selected audit-first design produces both:

1. a 2,879-bp linear cassette — `M73459.1[1..1049] +
	 NM_018790.3[199..1389] + M73460.1[1..639]`; and
2. a 5,565-bp circular visualization record — public pUC19 `M77789.2[1..270] +
	 cassette + M77789.2[271..2686]`, placing the unchanged cassette at the SmaI
	 blunt cut between backbone bases 270 and 271.

Completed evidence gates:

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
	exact coordinates, acceptance gates, and the evidence boundary.

Still in progress:

- deterministic build and validation programs;
- annotated linear and circular GenBank/FASTA deliverables;
- linear and circular SVG maps plus a self-contained HTML report;
- manifest, generated-artifact checksums, automated tests, and CPCS verification
	report; and
- import and graphical-map inspection in the free ApE plasmid editor.

No complete public base-level record for `pTB38`, `pTB41`, `pXM1`, or `pXM2`
has been located. Those constructs remain literature precedent only; no sequence
has been inferred for them.

Notes:

- The full extracted assembly package is large and was not committed to avoid repository bloat.
- Checksums and retrieval instructions are in `README.md` and `SHA256SUMS.txt` in the data folder.
