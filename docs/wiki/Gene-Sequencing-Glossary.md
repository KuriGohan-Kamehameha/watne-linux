# Gene Sequencing and Physarum Vector Glossary

This glossary records the material scientific, sequence-record, vector, and design terms encountered in the Arc/Physarum companion thread. Definitions distinguish facts supported by accession records or primary literature from hypothetical design language.

## Sequence records, formats, and units

| Term | Definition |
|---|---|
| **Accession** | Stable database identifier for a biological record. A suffix such as `.3` is the record version and must be retained for reproducibility. |
| **NCBI Gene** | NCBI record that aggregates information about a gene and links to transcripts, proteins, genomic loci, and literature. |
| **RefSeq** | NCBI's curated reference-sequence collection. Prefix `NM_` denotes a curated protein-coding mRNA; `NP_` denotes its protein product. |
| **GenBank** | Public nucleotide-sequence archive and, in this wiki, the annotated flat-file format containing sequence plus features and qualifiers. |
| **NCBI Assembly** | Record describing a submitted genome assembly and its component sequences, statistics, provenance, and status. |
| **`NM_018790` / `NM_018790.3`** | Mouse Arc transcript accession. Version `.3` is 3,059 nt; its annotated CDS is bases 199..1389 (1,191 nt including the stop codon). |
| **`NP_061260.1`** | Protein translated from the `NM_018790.3` CDS: mouse activity-regulated cytoskeleton-associated protein, 396 aa. |
| **`GCA_000413255.3`** | Current scaffold-level assembly `Physarum_polycephalum-10.0`, strain LU352. NCBI currently assigns it to *Badhamia polycephala*. It has 69,687 scaffold records and 205,175,886 total bases, including unresolved `N` bases. |
| **`M73459.1`** | 1,107-bp Physarum actin 5′ genomic record. NCBI annotates bases 1..1049 as a promoter and the native gene beginning at 1050. |
| **`M73460.1`** | 639-bp Physarum actin 3′ record annotated as 3′ UTR. It is not explicitly annotated by NCBI as a terminator or polyadenylation signal. |
| **`M77789.2`** | NCBI record for the complete 2,686-bp circular cloning vector pUC19. |
| **`L09137.2`** | NCBI record for the complete 2,686-bp circular cloning vector pUC19c. |
| **FASTA** | Plain-text sequence format: a `>` header followed by nucleotide or amino-acid sequence. FASTA does not carry a rich feature table. |
| **GenBank flat file** | Text format that combines a sequence with coordinates, feature types, qualifiers, references, and taxonomy. |
| **Feature annotation** | A typed interval on a sequence, such as `CDS`, promoter, gene, or 3′ UTR, supported by qualifiers and provenance. |
| **Genome assembly** | Reconstruction of a genome from sequencing reads. It is not automatically a complete chromosome-level sequence or a gene annotation. |
| **Contig** | Continuous assembled sequence with no assembly gap inside it. |
| **Scaffold** | Ordered/oriented collection of contigs that may contain unresolved gaps represented by `N`. |
| **`N` base** | Placeholder for an unresolved nucleotide in an assembly. It is not a fifth DNA base. |
| **bp / kb / kbp** | Base pair; 1 kb or kbp is approximately 1,000 base pairs of double-stranded DNA. |
| **nt** | Nucleotide, commonly used for RNA or a single sequence strand. |
| **aa** | Amino acid; unit used for protein length. |
| **Coordinates** | Numbered interval locating a feature in a specific sequence version. Coordinates are version-dependent and generally 1-based in GenBank records. |
| **Base-level or sequence-resolved map** | Design for which every nucleotide is known and traceable, not merely the order of functional modules. |
| **Topology-only map** | Diagram showing module order and orientation without claiming a complete nucleotide sequence. |
| **Auditable map** | Map whose parts cite accession versions, coordinates, source records, and explicit uncertainty. |

## Organisms, cell forms, genes, and proteins

| Term | Definition |
|---|---|
| ***Mus musculus*** | House mouse; source organism for `NM_018790.3` and `NP_061260.1`. |
| ***Physarum polycephalum*** | Historical and widely used name for the laboratory acellular slime mold discussed in the papers and vector names. |
| ***Badhamia polycephala*** | Current NCBI organism name attached to taxon 5791 and assembly `GCA_000413255.3`; the assembly name still contains *Physarum polycephalum*. |
| **LU352** | Haploid Physarum amoebal strain used for the genome assembly and in the 1993 stable-transformation work. |
| **Amoeba / amoebae** | Uninucleate, motile Physarum cell stage used in stable-transformation experiments. |
| **Plasmodium / plasmodia** | Multinucleate feeding stage of Physarum; not the malaria parasite genus in this context. |
| **Microplasmodium / microplasmodia** | Small plasmodial form maintained in liquid culture and used in transient-expression studies. |
| **Haploid** | Having one chromosome set; the assembly report describes the submitted genome assembly as haploid. |
| **Nuclear genome** | DNA housed in nuclei. The 1993 `PardC-hph` transformants carried a stable single-copy integration in this genome. |
| **Mitochondrion / mitochondrial genome** | Organelle and its separate DNA. One consulted paper tested DNA electroporation into isolated Physarum mitochondria; that is distinct from nuclear expression-vector work. |
| **Arc / Arg3.1** | Activity-regulated cytoskeleton-associated protein, a neuronal immediate-early gene product with retrotransposon-derived, Gag-like capsid-forming properties. |
| **Immediate-early gene** | Gene induced rapidly after a stimulus without requiring new protein synthesis for its initial activation. Arc is commonly classified this way. |
| **Gag-like** | Structurally/evolutionarily reminiscent of retroviral Gag proteins. It does not mean Arc is a current infectious retrovirus. |
| **Capsid** | Self-assembled protein shell. Arc can form retrovirus-like capsids that package RNA under studied conditions. |
| **Actin** | Conserved cytoskeletal protein. Physarum actin loci supplied regulatory sequences used in historical transformation vectors. |
| **`ardC`** | Physarum actin gene whose upstream and downstream regulatory regions are called `PardC` and `TardC` in the vector literature. |
| **`ardD`** | Another Physarum actin gene used in the homologous gene-replacement study. |
| **`ardD1`** | Mutant `ardD` allele altering the protein's carboxy-terminal region; used to demonstrate homologous replacement in Physarum. |
| **Ubiquitin** | Small protein covalently attached to other proteins. Ubiquitin genes are often highly expressed, but the companion thread did not establish a sequence-validated Physarum ubiquitin promoter for this construct. |
| **`hph`** | Gene encoding hygromycin B phosphotransferase (hygromycin-B kinase), which inactivates hygromycin B and provides a selectable resistance phenotype. |
| **Hy / HyR** | Paper shorthand for hygromycin B and hygromycin-resistant, respectively. |
| **`pelf1` / PELF1** | Physarum transcription elongation factor homolog studied with the `pXM2-pelf1` construct; PELF1-RFP denotes its red-fluorescent fusion product. |
| **DsRed1 / RFP** | Red fluorescent protein reporter used to visualize transient expression. `DsRed1` is the specific reporter gene; RFP is the general phenotype/protein label. |
| **`Amp` / `bla` / β-lactamase** | Bacterial ampicillin-resistance marker shown as `Amp` on the pTB38 map; `bla` encodes β-lactamase. |
| **`ars1`** | *Schizosaccharomyces pombe* autonomously replicating sequence carried by pTB38 to support plasmid replication in yeast contexts. It is not evidence of autonomous replication in Physarum. |
| **`ura4+` (rendered `ura4*` in the search summary)** | *Schizosaccharomyces pombe* `ura4+` selectable gene carried by pTB38. The primary paper and map show a superscript plus; `ura4*` was an inaccurate rendering encountered in the search summary. |
| **Wild type (`wt`)** | Reference non-mutant genotype or sequence used for comparison. |
| **38T1, 38T2, 41T1, 41T2** | Hygromycin-resistant Physarum transformant clone names from the 1993 paper; the number links each clone to pTB38 or pTB41 treatment. |

## Functional sequence and expression terms

| Term | Definition |
|---|---|
| **Promoter** | DNA region that recruits transcription machinery and determines where/directionally how transcription begins. |
| **`PardC`** | Approximately 1-kb promoter region upstream of Physarum `ardC`. Primary literature also demonstrates replication-origin/replicator activity in this chromosomal fragment. |
| **Terminator** | Sequence context that contributes to transcription termination and/or proper 3′-end formation. A 3′ UTR alone is not automatically a validated terminator. |
| **`TardC`** | `ardC` downstream/termination element named in Physarum vector literature and carried by pTB38/pTB41. It should not be assumed to be identical to all of `M73460.1` without sequence-level mapping. |
| **3′ UTR** | Transcribed but untranslated region after a coding sequence. It may contain RNA-processing signals but is not synonymous with a promoter or terminator. |
| **Polyadenylation signal / poly(A)** | Eukaryotic RNA signal and processing event that specify cleavage and addition of a poly(A) tail. This is related to—but not identical with—transcription termination. |
| **CMV IE promoter** | Human cytomegalovirus immediate-early promoter used in many mammalian expression vectors; replaced by `PardC` in the pXM design. |
| **SV40 polyA** | Simian virus 40 polyadenylation/3′-processing element; replaced by `TardC` in the pXM design. |
| **SP6 and T7 promoters** | Bacteriophage RNA-polymerase promoters present in pGEM-family cloning backbones for in-vitro transcription; they are not Physarum expression promoters. |
| **Transcription machinery** | RNA polymerase plus associated factors that recognize promoters and synthesize RNA. Promoter compatibility is host/context dependent. |
| **CDS (coding sequence)** | Nucleotide interval translated into protein, from start codon through stop codon. The Arc CDS is only part of the full 3,059-nt mRNA. |
| **Start codon / stop codon** | Translation boundary signals. A stop codon ends translation; it is not a transcription terminator. |
| **mRNA** | Messenger RNA containing a translated CDS plus untranslated regions and processing features. |
| **cDNA** | DNA copy representing an RNA transcript. A mature-mRNA-derived cDNA is intron-free; “pre-spliced cDNA” in the prompt means a sequence corresponding to already-spliced mRNA. |
| **Intron** | Intervening sequence removed from a precursor RNA during splicing. |
| **Splicing** | RNA-processing reaction that removes introns and joins exons. |
| **Expression cassette** | Functionally grouped promoter, cargo/CDS, and 3′ processing/termination region. `PardC-hph-TardC` is the historical selectable cassette. |
| **Cargo / transgene** | Inserted sequence intended to be carried or expressed; Arc is the proposed cargo in the hypothetical map. |
| **Heterologous gene** | Gene introduced into a different species or expression context. Mouse Arc in Physarum would be heterologous. |
| **Reporter** | Gene whose detectable output reports expression or localization; DsRed1/RFP is the reporter in pXM vectors. |
| **Selectable marker** | Gene enabling transformed cells to survive or grow under selection; `hph` is selected with hygromycin B. |
| **MCS / polylinker** | Multiple cloning site: short engineered region containing several restriction-enzyme sites for inserting DNA. |
| **Backbone** | Vector sequence providing propagation, selection, and cloning functions apart from the experimental expression cassette. |
| **Bacterial `ori`** | Origin of replication used to maintain a plasmid in bacteria. It does not imply replication in Physarum. |
| **`f1 ori`** | Filamentous-phage origin carried by pGEM7Zf(+)/pTB41 for producing single-stranded vector DNA in a suitable bacterial/helper-phage system; it is not a Physarum replication origin. |
| **Circular plasmid** | Covalently closed or circular DNA molecule typically used as a cloning vector. |
| **Linear DNA** | DNA with free ends. In the cited Physarum work, linear and circular inputs behaved differently in some transformation contexts. |

## Plasmids and construct names

| Term | Definition |
|---|---|
| **pTB38** | 8.4-kb pGEM3Z-based Physarum transformation plasmid from the 1993 paper. Its mapped features include `PardC-hph-TardC`, yeast `ars1`/`ura4+`, bacterial `Amp` and `ori`, an MCS, and SP6/T7 backbone promoters. It supported stable, selectable, single-copy nuclear integration, but no complete public base-level sequence was located in the companion research. |
| **pTB41** | 8.4-kb pGEM7Zf(+)-based relative of pTB38 carrying `PardC-hph-TardC`, no yeast sequences, and a 2.1-kb repeated Physarum genomic fragment. |
| **pTB33** | Earlier `PardC-hph` construct used as a parent of pTB38; the paper states that it lacks `TardC`. |
| **pLAV-TerC** | Source plasmid for the `TardC` PstI fragment inserted during pTB38 construction. |
| **pTB37** | Intermediate made by inserting the pTB33 `PardC-hph` fragment into pGEM7Zf(+). |
| **pTB40** | Intermediate made by adding the `TardC` fragment to pTB37. |
| **pLG83** | Published source plasmid for the `hph` fragment used in related pTB constructs. |
| **pTB20** | pGEM7Zf(+)-based intermediate carrying the `hph` fragment and used to make a small Physarum genomic-fragment library. |
| **pTB21** | Library plasmid containing the 2.1-kb repeated Physarum XbaI fragment later incorporated into pTB41. |
| **pGEM3Z** | Commercial bacterial cloning vector used as the pTB38 backbone. |
| **pGEM7Zf(+)** | Commercial bacterial cloning vector used for pTB41 and several intermediates. |
| **pDsRed1-N1** | Mammalian red-fluorescent expression plasmid whose CMV IE and SV40 poly(A) elements were replaced with Physarum `PardC`/`TardC` to make one pXM design. |
| **pXM1** | In the 2009 abstract, pDsRed1-N1-derived Physarum transient-expression construct made by substituting `PardC` and `TardC` for the mammalian CMV IE and SV40 poly(A) regions. |
| **pXM2** | In the same abstract, pTB38-derived construct in which `PardC-hph-TardC` was replaced by `PardC-MCS-DsRed1-TardC`. |
| **pXM2-pelf1** | pXM2 derivative carrying reconstituted Physarum `pelf1`, used to express a PELF1-RFP fusion. |
| **pUC19** | Standard 2,686-bp high-copy *E. coli* cloning vector with bacterial replication, ampicillin selection, and lacZα/MCS functions; considered as a fully sequence-resolved fallback backbone, not as an established Physarum vector. |
| **pUC-derived backbone** | Generic design shorthand for a backbone derived from pUC plasmids. It describes bacterial propagation functions, not host-specific Physarum expression. |
| **Approximate pTB38 reconstruction** | Inference of unknown bases from diagrams and related constructs. The companion thread rejected this as scientifically unauditable. |

## Transformation, genetics, replication, and assays

| Term | Definition |
|---|---|
| **Transformation** | Introduction and establishment of foreign DNA in a cell. DNA uptake alone does not prove expression or integration. |
| **Electroporation** | Use of a brief electric field to permeabilize cells or organelles and promote DNA uptake. |
| **Transient expression** | Detectable expression without demonstrating stable genomic inheritance; pXM1/pXM2 RFP signals were reported 24–48 hours after electroporation. |
| **Stable transformation** | Heritable maintenance of introduced DNA over growth, often after genomic integration and selection. |
| **Integration** | Incorporation of introduced DNA into a chromosome. |
| **Single-copy integration** | One integrated copy per haploid nuclear genome, as inferred for the 1993 transformants. |
| **Ectopic position** | Chromosomal location different from the element's native locus. The `PardC` fragment retained promoter and replicator activity at tested ectopic sites. |
| **Homologous recombination** | DNA exchange guided by substantial sequence similarity. |
| **Homologous gene replacement** | Replacement of a native allele with an introduced homologous allele; demonstrated with `ardD1`. |
| **Nonhomologous integration** | Integration not directed by the intended homologous locus; judged the most likely explanation for the 1993 pTB38/pTB41 events. |
| **Mutant allele** | Alternative gene version containing a defined mutation, such as `ardD1`. |
| **Transformant** | Cell or clone that acquired the selected introduced DNA/phenotype. |
| **Selection** | Growth condition used to enrich cells carrying a selectable marker, such as hygromycin B selection for `hph`. |
| **Phenotype** | Observable trait; hygromycin resistance and red fluorescence are examples in these studies. |
| **Meiosis** | Reductional cell division producing haploid progeny; the resistance determinant was tested for inheritance through meiosis. |
| **Replication origin** | Site where DNA replication initiates. The `PardC` upstream region contains origin activity in its native and tested ectopic contexts. |
| **Replicator** | Cis-acting DNA sequence sufficient to specify initiation of replication in the tested chromosomal context. |
| **Replicon** | DNA domain replicated from a particular origin. |
| **Replication fork** | Moving junction at which DNA is copied outward from an origin. |
| **S phase** | Cell-cycle phase during which DNA replication occurs. The `PardC` origin was reported to activate early in S phase. |
| **Autonomously replicating sequence (ARS)** | Sequence that can support extrachromosomal replication in a compatible host. `ars1` is a yeast ARS; the Physarum paper explicitly noted that a functional Physarum ARS assay was still needed. |
| **Cis-acting element** | DNA/RNA sequence affecting a molecule or nearby locus on the same molecule. |
| **Trans-acting factor** | Diffusible molecule, usually RNA or protein, that acts on other molecules or loci. |
| **Restriction enzyme/site** | Sequence-specific DNA-cutting enzyme and its recognition site. The papers/maps use sites including HindIII, BamHI, BglII, EcoRI, KpnI, NsiI, XbaI, ApaI, PstI, and SmaI. |
| **Restriction mapping** | Inferring construct structure from known cut sites and fragment sizes. |
| **Ligation** | Enzymatic joining of DNA ends during plasmid construction. |
| **Blunt-ended DNA** | DNA end lacking a single-stranded overhang; the pTB38 construction used Klenow polymerase to blunt-end a fragment before ligation. |
| **Southern blot** | DNA assay in which restriction fragments are separated, transferred, and hybridized with a labeled probe to detect copy number and integration patterns. |
| **Hybridization probe** | Labeled complementary nucleic acid used to detect a target sequence on a blot. |
| **Two-dimensional agarose gel electrophoresis** | Method that separates replication intermediates by mass and shape to detect origin and fork structures. |
| **Fluorescence microscopy** | Imaging of fluorescent reporters such as RFP. |
| **Confocal microscopy** | Optical-sectioning fluorescence microscopy used to localize PELF1-RFP/RFP signals. |
| **RT-PCR** | Reverse transcription followed by PCR; converts RNA to cDNA before amplification to test for transcripts. |
| **RNA editing** | Post- or co-transcriptional alteration of RNA sequence relative to its DNA template. Physarum mitochondrial editing is a separate issue from nuclear `PardC` expression-vector design. |
| **Endogenous / exogenous** | Endogenous means originating within the organism or organelle; exogenous means introduced from outside. |
| **Chimeric construct/template** | Engineered molecule joining sequences from different genes or sources. |

## Design and software language

| Term | Definition |
|---|---|
| **Benchling** | Web-based molecular-biology design and sequence-annotation platform mentioned as an import target. |
| **SnapGene** | Desktop molecular-design software for annotated linear/circular sequence maps and cloning simulations. |
| **Three-zone cassette** | Companion shorthand for `[Physarum promoter] → [Arc CDS] → [Physarum 3′ element]`. It is an organizational map, not proof of function. |
| **Complete circular plasmid map** | Map containing a fully specified circular backbone plus all inserted features and coordinates. |
| **Backbone-neutral conceptual circle** | Diagram of functional modules without choosing or asserting a particular nucleotide-resolved backbone. |
| **Biological precedent** | Previously reported construct or architecture supporting plausibility. pTB38 is precedent for `PardC-cargo-TardC`, not a substitute for its unavailable complete sequence. |
| **Fallback backbone** | Sequence-resolved standard vector used when the preferred historical backbone cannot be reconstructed auditably. pUC19 was considered only in this role. |
| **Functional expression vector** | Vector empirically shown to express a cargo in the target context. A digitally concatenated sequence remains hypothetical until tested. |

## Primary sources

- Mouse Arc RefSeq: https://www.ncbi.nlm.nih.gov/nuccore/NM_018790.3
- Physarum assembly: https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_000413255.3/
- Physarum actin 5′ record: https://www.ncbi.nlm.nih.gov/nuccore/M73459.1
- Physarum actin 3′ record: https://www.ncbi.nlm.nih.gov/nuccore/M73460.1
- pUC19 sequence: https://www.ncbi.nlm.nih.gov/nuccore/M77789.2
- Stable selectable transformation and pTB38/pTB41: https://pubmed.ncbi.nlm.nih.gov/8224865/
- Full pTB38/pTB41 paper and plasmid map: https://oncology.wisc.edu/dove/pdfs/Burland207.pdf
- `PardC` promoter/replicator study: https://pmc.ncbi.nlm.nih.gov/articles/PMC84143/
- Homologous `ardD1` replacement: https://pmc.ncbi.nlm.nih.gov/articles/PMC1206314/
- pXM1/pXM2 transient-expression abstract: https://pubmed.ncbi.nlm.nih.gov/19777812/
- Physarum mitochondrial electroporation/RNA editing: https://pmc.ncbi.nlm.nih.gov/articles/PMC5192504/

## Provenance cautions

1. The complete pTB38 nucleotide sequence was not found in a public accession during the companion research; its definition above is derived from the published map and construction text.
2. `M73460.1` is annotated as a 3′ UTR, not explicitly as `TardC` or a validated terminator.
3. Historical Physarum actin flank records did not exactly match the downloaded LU352 assembly in a full-length exact-string search.
4. A promoter-cargo-3′-element concatenation is a hypothetical sequence map, not evidence of expression, RNA processing, capsid assembly, or biological function in Physarum.
