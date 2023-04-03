# Arabidopsis thaliana Genotype Analysis in R

The following project was done to understand how the differences in gene expression, within an assigned set of genes, vary by genotype in samples of *Arabidopsis thaliana* that were collected under different conditions (light and dark). This project was completed during my senior year of university in my bioinformatics class.

## Libraries Used:
- BiocParallel
- DESeq2
- ggplot2
- pheatmap

## Applied Skills:
- R programming: DESeq, Principal Component Analysis, Log transforming data
- Data Visualization: strip chart, heatmap, ggplot for pca visualizations

## The general workflow of the project is as follows:
1. Differential gene expression analysis of RNA-Seq data (DESeq)
2. Log transform the normalized data from the resulting dds object created in step 1
3. Principal component analysis (PCA) on the log transformed data
4. Visualize the first two principal components since they describe the most variation
5. Filter the data to only the assigned gene select
6. Perform another PCA on the filtered data
7. Create a clustered heatmap from the differences in the log-transformed normalized expression level and the mean expression level of each of the genes in the assigned gene set
8. Create a strip chart using a filtered subset of the genes according to the previous DESeq results

## Favorite insight from the project:
According to the heatmap, the LHCB2.2 gene was shown to be highly expressed when the sample was collected in the dark but almost wholly inhibited when collected in the light. This is interesting because *Arabidopsis thaliana* is a flowering plant and the LHCB2.2 gene encodes for a protein found in the photosystem II complex which is light dependent. Yet, after doing some research, it seems that *Arabidopsis thaliana* has had documented increases in chloroplast proteins in complete darkness. (https://pubmed.ncbi.nlm.nih.gov/1380166/)
