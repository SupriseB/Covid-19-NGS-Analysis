

# Define variables
SRA_ACCESSION="ERR5743893 ERR5556343 SRR13500958 ERR5181310 ERR5405022"
REF_GENOME="MN908947.fasta"  # Path to the SARS-CoV-2 reference genome
THREADS=4  # Number of CPU threads to use
OUTPUT_DIR="covid19" 

# Function to install required tools
install_tools() {
    echo "Installing required tools..."
    
    # Update package list
    sudo apt-get update

    # Install SRA Toolkit
    echo "Installing SRA Toolkit..."
    sudo apt-get install -y sra-toolkit

    # Install FastQC
    echo "Installing FastQC..."
    sudo apt-get install -y fastqc

    # Install Trimmomatic
    echo "Installing Trimmomatic..."
    sudo apt-get install -y trimmomatic

    # Install BWA
    echo "Installing BWA..."
    sudo apt-get install -y bwa

    # Install Samtools
    echo "Installing Samtools..."
    sudo apt-get install -y samtools

    # Install VCFtools
    echo "Installing VCFtools..."
    sudo apt-get install -y vcftools

    # Install FreeBayes
    echo "Installing FreeBayes..."
    sudo apt-get install -y freebayes

    # Install MultiQC
    echo "Installing MultiQC..."
    sudo apt-get install -y multiqc

    echo "All required tools have been installed."
}

# Call the function to install tools
install_tools

# Create output directory
mkdir -p $OUTPUT_DIR

# Step 1: Download sequencing data from SRA
echo "Downloading sequencing data for $SRA_ACCESSION..."
for accession in $SRA_ACCESSION; do
    fastq-dump --split-files --gzip --outdir $OUTPUT_DIR $accession
done

# Step 2: Perform Quality Control using FastQC
echo "Running quality control on the downloaded data..."
for accession in $SRA_ACCESSION; do
    fastqc $OUTPUT_DIR/${accession}_1.fastq.gz $OUTPUT_DIR/${accession}_2.fastq.gz -o $OUTPUT_DIR
done

# Step 3: Generate MultiQC report
echo "Generating MultiQC report..."
multiqc $OUTPUT_DIR -o $OUTPUT_DIR/multiqc_report

# Step 4: Trim the data for better quality using Trimmomatic
echo "Trimming low-quality reads and adapters..."
for accession in $SRA_ACCESSION; do
    trimmomatic PE -threads $THREADS \
        $OUTPUT_DIR/${accession}_1.fastq.gz $OUTPUT_DIR/${accession}_2.fastq.gz \
        $OUTPUT_DIR/${accession}_1_paired.fastq.gz $OUTPUT_DIR/${accession}_1_unpaired.fastq.gz \
        $OUTPUT_DIR/${accession}_2_paired.fastq.gz $OUTPUT_DIR/${accession}_2_unpaired.fastq.gz \
        ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:36
done

# Step 5: Index reference genome
echo "Indexing the reference genome..."
bwa index $REF_GENOME

# Step 6: Align to the reference genome using BWA
echo "Aligning reads to the reference genome $REF_GENOME..."
for accession in $SRA_ACCESSION; do
    bwa mem -t $THREADS $REF_GENOME \
        $OUTPUT_DIR/${accession}_1_paired.fastq.gz $OUTPUT_DIR/${accession}_2_paired.fastq.gz > $OUTPUT_DIR/${accession}.sam
done

# Step 7: Convert SAM to BAM and sort
echo "Converting SAM to BAM and sorting..."
for accession in $SRA_ACCESSION; do
    samtools view -@ $THREADS -Sb $OUTPUT_DIR/${accession}.sam | samtools sort -@ $THREADS -o $OUTPUT_DIR/${accession}.sorted.bam
done

# Step 8: Index the BAM files
echo "Indexing the BAM files..."
for accession in $SRA_ACCESSION; do
    samtools index $OUTPUT_DIR/${accession}.sorted.bam
done

samtools faidx $REF_GENOME

# Step 9: Variant calling using FreeBayes
echo "Calling variants..."
for accession in $SRA_ACCESSION; do
    freebayes -f $REF_GENOME -p 1 $OUTPUT_DIR/${accession}.sorted.bam > $OUTPUT_DIR/${accession}.vcf
done

# Step 10: Filter variants using VCFtools for each sample
echo "Filtering low-quality variants..."
for accession in $SRA_ACCESSION; do
    input_vcf="$OUTPUT_DIR/${accession}.vcf"
    output_vcf="$OUTPUT_DIR/${accession}_filtered"

    # Check if the input VCF exists
    if [[ -f $input_vcf ]]; then
        echo "Processing $input_vcf..."
        vcftools --vcf $input_vcf --minQ 10 --recode --recode-INFO-all --out $output_vcf
    else
        echo "Input VCF file not found: $input_vcf"
    fi
done

# Step 11: Generate a summary of all variants in a single CSV file
echo "Summarizing variants for all samples in CSV format..."
output_csv="$OUTPUT_DIR/all_samples_variants.csv"

# Add header to the CSV file
echo "CHROM,POS,REF,ALT,QUAL,DP,AF,Sample" > $output_csv

# Loop through each sample and append its variants to the CSV
for accession in $SRA_ACCESSION; do
    bcftools query -f '%CHROM,%POS,%REF,%ALT,%QUAL,%INFO/DP,%INFO/AF,'$accession'\n' $OUTPUT_DIR/${accession}_filtered.recode.vcf >> $output_csv
done

echo "Variants summarized in $output_csv"
echo "Analysis complete! Results are stored in the $OUTPUT_DIR directory."

