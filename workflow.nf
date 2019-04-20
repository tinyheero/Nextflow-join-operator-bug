snvToSamplesMappingFile = file("snv_to_sample_mappings.tsv")

// Create mutationBamsChannel
mutationBamsChannel = Channel
     .fromPath("${snvToSamplesMappingFile}")
    .splitCsv(header: true, sep: "\t", by: 1)
    .map { item ->
        variant = item["key"]
            .replaceAll(/:/, "_")
            .replaceAll(/>/, "_")
        bams = item["samples_to_use"]
            .split(",")
            .collect { sample_id ->
                file("data/bams/${sample_id}.bam")
            }
        return [variant, bams]
    }

mutationBamsChannel.into { mutationBamsChannel1; mutationBamsChannel2 }
mutationBamsChannel1
    .count()
    .view { num -> "Number of elements in mutationBamsChannel: $num" }

// Create vcfChannel
vcfChannel = Channel
    .fromPath("${snvToSamplesMappingFile}")
    .splitCsv(header: true, sep: "\t", by: 1)
    .map { item ->
        variant = item["key"]
            .replaceAll(/:/, "_")
            .replaceAll(/>/, "_")
        vcf = variant + ".vcf"
        return [variant, vcf]
    }

vcfChannel.into { vcfChannel1; vcfChannel2 }
vcfChannel1 
    .count()
    .view { num -> "Number of elements in vcfChannel: $num" }

// Join the two channels
joinedChannel = mutationBamsChannel2
    .join(vcfChannel2, by: 0)
    .count()
    .view { num -> "Number of elements after joining the mutationBamsChannel and vcfChannel: $num" }
