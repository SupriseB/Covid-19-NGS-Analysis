# Load necessary libraries
library(tidyverse)

# Set the path to your CSV file
csv_file <- "C:/Users/Suprise Baloyi/Downloads/all_samples_variants"

# Read the CSV file
variants_data <- read.csv(csv_file)

# Check the structure of the data
str(variants_data)
# Check the column names of the dataframe
colnames(variants_data)

# Summary statistics
summary(variants_data)

# Load necessary libraries for visualization
library(ggplot2)
library(dplyr)

# Visualize the distribution of Quality (QUAL) scores
ggplot(variants_data, aes(x = QUAL)) +
  geom_histogram(bins = 30, fill = "blue", color = "black") +
  labs(title = "Distribution of Quality Scores", x = "Quality Score (QUAL)", y = "Frequency")



# Visualize the relationship between Depth of Coverage (DP) and Allele Frequency (AF)
ggplot(variants_data, aes(x = DP, y = AF)) +
  geom_point(alpha = 0.5) +
  labs(title = "Depth of Coverage vs. Allele Frequency", x = "Depth of Coverage (DP)", y = "Allele Frequency (AF)") +
  theme_minimal()


#Visualize variant type distribution
variants_data$variant_type <- ifelse(nchar(variants_data$REF) == 1 & nchar(variants_data$ALT) == 1, "SNP", "Indel")
# Bar plot
ggplot(variants_data, aes(x = variant_type, fill = variant_type)) +
  geom_bar() +
  labs(title = "Variant Type Distribution", x = "Variant Type", y = "Count") +
  theme_minimal()


# Filter for high-quality variants (e.g., QUAL > 20)
high_quality_variants <- variants_data %>% filter(QUAL > 20)

# Visualize the number of high-quality variants per sample
high_quality_counts <- high_quality_variants %>% group_by(Sample) %>% summarize(Count = n())

ggplot(high_quality_counts, aes(x = Sample, y = Count)) +
  geom_bar(stat = "identity", fill = "green") +
  labs(title = "High-Quality Variants per Sample", x = "Sample", y = "Number of High-Quality Variants") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))









