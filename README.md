<!-- dx-header -->
# eggd_ctatsplicing

<!-- Insert a description of your app here -->
## What does this app do?
eggd_ctatsplicing is a DNA-Nexus app to use CTAT-Splicing (https://github.com/TrinityCTAT/CTAT-SPLICING).
For a given sample, the app detects aberrant splicing events/introns and highlights those enriched in cancer.
More info on how the introns were found enriched in cancer is reported in the CTAT-Splicing GitHub.

## What are the typical use cases for this app?
eggd_ctatsplicing can be used to detect aberrant splicing events happening in cancer. For example, eggd_ctatsplicing can identify the MET14del which is often present in lung adenocarcinoma. The app works with transcriptome (bam files from RNA-Seq).

## What are the inputs?
### Dependencies:
<li>
<code>--ctatsplicing_tar</code>
:(file) CTAT-Splicing docker tar file.
<li>

<li>
<code>--genome_lib</code>
:(file) A CTAT genome library, which is a reference file bundle required by Trinity CTAT tools. This contains the genome indices and reference genome that are needed to run CTAT-Splicing.
<li>

<li>
<code>--cancer_splicing_index</code>
:(file) An index file for the ~24k introns that are enriched for splicing in tumor tissues as compared to normal tissues. It is required to run CTAT-Splicing. Generated with CTAT-SPLICING/prep_genome_lib/ctat-splicing-lib-integration.py.
<li>

<li>
<code>--refGene</code>
:(file) The refGene.bam required to run CTAT-Splicing. Generated with CTAT-SPLICING/prep_genome_lib/ctat-splicing-lib-integration.py.
<li>

<li>
<code>--refGene_sort</code>
:(file) The refGene.sort.bed.gz required to run CTAT-Splicing. Generated with CTAT-SPLICING/prep_genome_lib/ctat-splicing-lib-integration.py.
<li>

<li>
<code>--refGene_sort_tbi</code>
:(file) The refGene.sort.bed.gz.tbi required to run CTAT-Splicing. Generated with CTAT-SPLICING/prep_genome_lib/ctat-splicing-lib-integration.py.
<li>


### Sample specific input files:
<li>
<code>--splice_junction</code>
:(file, *.SJ.out.tab) SJ.out.tab file identifing introns and reported by STAR/eggd_staraligner. Input file required.
<li>

<li>
<code>--chimeric_junction</code>
:(file, *.chimeric.out.junction) Chimeric read alignments reported by STAR/eggd_staraligner. Input file required.
<li>

<li>
<code>--bam</code>
:(file, *.bam) RNA-Seq BAM file from STAR/eggd_staraligner. Required for visualization, ideally coordinate-sorted or will be coordinate-sorted as part of the CTAT-Splicing run.
<li>

<li>
<code>--bam_index</code>
:(file, *.bai) RNA-Seq BAM Index file from STAR/eggd_staraligner.
<li>

## What are the outputs?
<li>
<code>--cancer_introns</code>
:(file, *cancer.introns) List of candidate cancer introns found in the tested sample.
<li>

<li>
<code>--introns</code>
:(file, *.introns) List of all introns found in the tested sample. Introns as reported by STAR and annotated according to genes containing corresponding splice junctions.
<li>

<li>
<code>--html_igv_introns</code>
:(file, **.ctat-splicing.igv.html) Self-contained interactive IGV-report in html format based on the *.cancer.introns report.
<li>

<li>
<code>--ctatsplicing_chckpts</code>
:(folder) CTAT-Splicing checkpoints folder tracking tests for each sub-task.
<li>


## How to run this app from command line?
```
add an example command of running this app from the CLI \
especially the (optional) inputs \
and recommended istance_type
```

### This app was made by EMEE GLH
