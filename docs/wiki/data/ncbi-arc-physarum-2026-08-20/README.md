# NCBI Arc / Physarum sequence bundle

Retrieved from NCBI on 2026-08-20.

## 1. Mouse Arc cargo

Authoritative record: https://www.ncbi.nlm.nih.gov/nuccore/NM_018790.3

- Requested accession: `NM_018790`
- Current record version at retrieval: `NM_018790.3`
- Organism: *Mus musculus*
- Transcript: 3,059 nt
- Annotated CDS: bases 199..1389, 1,191 nt including the terminal stop codon
- Protein: `NP_061260.1`, 396 aa

Files:

- `NM_018790.3.gb` — complete GenBank record and feature annotations
- `NM_018790.3.mrna.fna` — complete 3,059-nt RefSeq mRNA
- `NM_018790.3.cds.fna` — extracted 1,191-nt Arc CDS; use this rather than the full mRNA as the cargo sequence in a digital coding-region map
- `NM_018790.3.protein.faa` — translated Arc protein

## 2. Physarum assembly

Authoritative record: https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_000413255.3/

- Assembly accession: `GCA_000413255.3` (current)
- Assembly name: `Physarum_polycephalum-10.0`
- NCBI's current organism name: *Badhamia polycephala* (the organism historically called *Physarum polycephalum*)
- Strain: LU352
- Level: scaffold
- FASTA records/scaffolds: 69,687
- Total FASTA length: 205,175,886 bases
- `N` bases: 15,199,212
- A/C/G/T bases: 189,976,674
- The current NCBI report has no gene annotation package for this assembly and flags the assembly as atypical/contaminated.

Files:

- `GCA_000413255.3_dataset.zip` — original NCBI Datasets archive
- `GCA_000413255.3_dataset/` — extracted package, including the genomic multi-FASTA and sequence report
- `GCA_000413255.3.dataset_report.json` — NCBI assembly metadata

All checksums embedded in the NCBI archive were verified after extraction.

## 3. Documented Physarum actin flanking references

These additional NCBI nucleotide records were downloaded because the assembly itself has no NCBI gene annotation:

- `M73459.1` — 1,107-bp actin 5′ genomic region. GenBank explicitly annotates bases 1..1049 as `regulatory_class="promoter"`; the gene begins at 1050 and the native actin CDS begins at 1083.
- `M73460.1` — 639-bp actin 3′ genomic region. GenBank annotates the whole record only as a 3′ UTR; it does **not** explicitly annotate a terminator or polyadenylation signal.

Files:

- `Physarum_actin_5prime_3prime_reference.gb`
- `Physarum_actin_5prime_3prime_reference.fna`

An exact full-length string search found neither historical flank record in the LU352 assembly. That can result from strain differences, assembly fragmentation, sequence revisions, or mismatches; an alignment-based mapping step is required before treating these records as loci from `GCA_000413255.3`.

## Digital map supported by the records

A provenance-preserving *hypothetical* map can be represented as:

`[M73459.1 promoter candidate, 1..1049] -> [NM_018790.3 Arc CDS, 199..1389] -> [M73460.1 3′-region candidate, 1..639]`

The directly concatenated length of those three intervals would be 2,879 bp. This is a sequence map, not a validated expression cassette: the 3′ record is not annotated as a terminator, the assembly lacks gene models, the historical flanks did not map exactly to LU352, and expression/processing in *Physarum* cannot be inferred from concatenation alone.
