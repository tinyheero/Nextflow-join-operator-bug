# Nextflow join bug

This repository provides an example of what seems to be a Nextflow join bug.
Given a `snv_to_sample_mappings.tsv` file that contains these contents:

```
key	samples_to_use
chr1:111969210_C>T	Ma-Mel-86a,Ma-Mel-86b,Ma-Mel-86c,Ma-Mel-86f
chr1:115527461_C>T	Ma-Mel-86b,Ma-Mel-86c,Ma-Mel-86f
chr1:11771998_G>A	Ma-Mel-86a,Ma-Mel-86b,Ma-Mel-86c,Ma-Mel-86f
chr1:150811945_G>A	Ma-Mel-86a,Ma-Mel-86b,Ma-Mel-86c,Ma-Mel-86f
chr1:158324250_C>T	Ma-Mel-86a,Ma-Mel-86b,Ma-Mel-86c
chr1:160783455_A>C	Ma-Mel-86c
chr1:172539301_C>T	Ma-Mel-86a,Ma-Mel-86b,Ma-Mel-86c,Ma-Mel-86f
chr1:204970385_G>A	Ma-Mel-86a,Ma-Mel-86b,Ma-Mel-86c,Ma-Mel-86f
chr1:205585769_G>A	Ma-Mel-86a,Ma-Mel-86b,Ma-Mel-86c,Ma-Mel-86f
```

There are total of 251 features (mutations). Two channels 
(`mutationBamsChannel`, `vcfChannel`) are created from this file. The 
`mutationBamsChannel` should have these contents:

```
[chr1_111969210_C_T, [/pipeline_runs/volume_2/nextflow_join_bug/data/bams/Ma-Mel-86a.bam, /pipeline_runs/volume_2/nextflow_join_bug/data/bams/Ma-Mel-86b.bam, /pipeline_runs/volume_2/nextflow_join_bug/data/bams/Ma-Mel-86c.bam, /pipeline_runs/volume_2/nextflow_join_bug/data/bams/Ma-Mel-86f.bam]]
[chr1_115527461_C_T, [/pipeline_runs/volume_2/nextflow_join_bug/data/bams/Ma-Mel-86b.bam, /pipeline_runs/volume_2/nextflow_join_bug/data/bams/Ma-Mel-86c.bam, /pipeline_runs/volume_2/nextflow_join_bug/data/bams/Ma-Mel-86f.bam]]
.
.
.
```

While the vcfChannel should have these contents:

```
[chr1_111969210_C_T, chr1_111969210_C_T.vcf]
[chr1_115527461_C_T, chr1_115527461_C_T.vcf]
.
.
.
```

What I would like to form is:

```
[chr1_111969210_C_T, [/pipeline_runs/volume_2/nextflow_join_bug/data/bams/Ma-Mel-86a.bam, /pipeline_runs/volume_2/nextflow_join_bug/data/bams/Ma-Mel-86b.bam, /pipeline_runs/volume_2/nextflow_join_bug/data/bams/Ma-Mel-86c.bam, /pipeline_runs/volume_2/nextflow_join_bug/data/bams/Ma-Mel-86f.bam], chr1_111969210_C_T.vcf]
[chr1_115527461_C_T, [/pipeline_runs/volume_2/nextflow_join_bug/data/bams/Ma-Mel-86b.bam, /pipeline_runs/volume_2/nextflow_join_bug/data/bams/Ma-Mel-86c.bam, /pipeline_runs/volume_2/nextflow_join_bug/data/bams/Ma-Mel-86f.bam], chr1_115527461_C_T.vcf]
```

I was hoping to achieve this with the `join` operator:

```
joinedChannel = mutationBamsChannel.join(vcfChannel, by: 0)
```

While this works, I don't seem to be able to get all the output returned. I 
expected 251 elements in the `joinedChannel`, but I never seem to get all 251
elements. Also, the number of elements in the `joinedChannel` changes across 
runs. For instance, running the `./run.sh` script 5 separate times gives me:

```
$> ./run.sh
N E X T F L O W  ~  version 19.01.0
Launching `workflow.nf` [sick_hilbert] - revision: e01d871b41
Number of elements in vcfChannel: 251
Number of elements in mutationBamsChannel: 251
Number of elements after joining the mutationBamsChannel and vcfChannel: 199
$> ./run.sh
N E X T F L O W  ~  version 19.01.0
Launching `workflow.nf` [festering_kare] - revision: e01d871b41
Number of elements in vcfChannel: 251
Number of elements after joining the mutationBamsChannel and vcfChannel: 193
Number of elements in mutationBamsChannel: 251
$> ./run.sh
N E X T F L O W  ~  version 19.01.0
Launching `workflow.nf` [clever_shirley] - revision: e01d871b41
Number of elements in vcfChannel: 251
Number of elements after joining the mutationBamsChannel and vcfChannel: 197
Number of elements in mutationBamsChannel: 251
$> ./run.sh
N E X T F L O W  ~  version 19.01.0
Launching `workflow.nf` [dreamy_church] - revision: e01d871b41
Number of elements in vcfChannel: 251
Number of elements in mutationBamsChannel: 251
Number of elements after joining the mutationBamsChannel and vcfChannel: 198
N E X T F L O W  ~  version 19.01.0
Launching `workflow.nf` [trusting_booth] - revision: e01d871b41
Number of elements in vcfChannel: 251
Number of elements in mutationBamsChannel: 251
Number of elements after joining the mutationBamsChannel and vcfChannel: 189
```

