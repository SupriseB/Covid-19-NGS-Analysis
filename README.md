# SARS-CoV-2 Sequencing Data Analysis Pipeline

This project provides a pipeline for analyzing SARS-CoV-2 sequencing data, including quality control, read trimming, alignment to a reference genome, variant calling, and filtering. The pipeline is designed to automate the analysis of multiple samples downloaded from the Sequence Read Archive (SRA) and generate key outputs such as quality control reports, trimmed reads, alignments, and variant calls.

## Prerequisites

Before running the pipeline, ensure that you have the following software tools installed:

- SRA Toolkit
- FastQC
- Trimmomatic
- BWA
- Samtools
- VCFtools
- FreeBayes
- MultiQC

These tools can be installed using the provided script, which will automatically handle their installation.

## Pipeline Overview

The pipeline processes sequencing data from SRA accessions and performs the following steps:

1. **Download sequencing data from SRA:** Retrieve raw sequencing data in FASTQ format using `fastq-dump`.
2. **Perform quality control using FastQC:** Assess the quality of raw sequencing reads.
3. **Generate a MultiQC report:** Combine all FastQC reports into a single interactive HTML report.
4. **Trim low-quality reads and adapters using Trimmomatic:** Clean the reads by removing low-quality regions and adapter sequences.
5. **Align reads to the SARS-CoV-2 reference genome (MN908947) using BWA:** Map the cleaned reads to the reference genome.
6. **Convert SAM files to BAM format and sort them using Samtools:** Convert alignment files from SAM format to the more compact BAM format and sort them by genomic coordinates.
7. **Index the BAM files:** Create an index of each BAM file to allow for fast querying.
8. **Perform variant calling using FreeBayes:** Identify genomic variants such as SNPs and indels in the aligned reads.
9. **Filter low-quality variants using VCFtools:** Remove low-quality variants from the VCF files.
10. **Summarize all variants into a CSV file:** Aggregate the variant data from all samples into a single CSV file for downstream analysis.

## Usage

### Install Required Tools and Run the Pipeline
### Configure the pipeline:
Modify the script to ensure that the correct SRA accessions and reference genome are specified (If now directly downloaded from database, use wget to obtain from specific database)
### Run the Pipeline:
./script.sh

1. **Clone this repository:**
    Clone the repository to your local machine:
   ```bash
   git clone <repository_url>
   cd <repository_directory>
2. **Output Files:**   
  Upon completion, the pipeline generates the following outputs in the specified output directory (covid19):

FastQC results: Individual quality control reports for each sequencing file.

MultiQC report: A combined report that summarizes all FastQC results in a single HTML file.

Trimmed reads: Files containing cleaned, high-quality reads after adapter removal and trimming.

BAM files: Aligned and sorted sequencing reads mapped to the SARS-CoV-2 reference genome.

VCF files: Variant Call Format (VCF) files containing identified variants for each sample.

Filtered VCF files: VCF files filtered for quality control to remove low-confidence variants.

CSV file: A summary CSV file (all_samples_variants.csv) that consolidates the variants from all samples, with fields for chromosome, position, reference, alternate alleles, quality score, depth, allele frequency, and sample name.

  ### Conclusion
  
This pipeline streamlines the analysis of SARS-CoV-2 sequencing data, providing essential outputs for downstream research and analysis. For any issues or contributions, please feel free to submit an issue or pull request on this repository.

   

















