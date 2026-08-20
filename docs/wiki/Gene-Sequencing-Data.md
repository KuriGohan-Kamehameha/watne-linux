# Gene Sequencing Data

This section collects accession-pinned sequence records, assembly metadata, vector-map research, and terminology used in the associated design threads.

## Data sets

- [NCBI Arc + Physarum dataset (2026-08-20)](NCBI-Arc-Physarum-2026-08-20.md) — mouse Arc mRNA/CDS/protein records, the Physarum assembly report, historical actin flanking records, checksums, and provenance notes.

## Reference

- [Gene Sequencing and Physarum Vector Glossary](Gene-Sequencing-Glossary.md) — terms, accessions, genes, regulatory elements, plasmids, methods, and design language encountered in the Arc/Physarum companion thread.
- [Physarum Arc Expression Vector Roadmap](Physarum-Arc-Expression-Vector-Roadmap.md) — evidence-gated progression from the digital map through native regulatory evidence, complete vector provenance, compatibility review, and conditional validation.

## Storage layout

Sequence artifacts are filed under:

- `docs/wiki/data/gene-sequencing-data/`

The full 205 Mb assembly FASTA is intentionally not stored in Git. Its NCBI accession, retrieval metadata, and archive checksum are retained so it can be downloaded reproducibly without bloating the repository.
