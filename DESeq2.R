# 5. Exploratory data analysis
library(DESeq2)
# Make sure that the file "counts.arranged.txt" is downloaded and setup on the right working directory
cts <- as.matrix(read.table("counts.arranged.txt", header = TRUE, row.names = "Geneid")) # extract table of counts

# Generate the coldata dataframe
samples_ID <- c("SRR7821918","SRR7821919","SRR7821920","SRR7821921","SRR7821922","SRR7821937","SRR7821938","SRR7821939",
                "SRR7821949","SRR7821950","SRR7821951","SRR7821952","SRR7821953","SRR7821968","SRR7821969","SRR7821970")
group <- c(rep("Lung_WT_Case",5),rep("Lung_WT_Control",3),rep("Blood_WT_Case",5),rep("Blood_WT_Control",3))
coldata <- data.frame(group,row.names = samples_ID)

colnames(cts) <- samples_ID

# Start differential expression analysis
dds <- DESeq2::DESeqDataSetFromMatrix(countData = cts, 
                                      colData = coldata, 
                                      design = ~ group)
dds <- DESeq2::DESeq(dds)
resultsNames(dds) #lists the coefficients
vsd <- DESeq2::vst(dds, blind = TRUE) # remove dependence of variance of the mean
DESeq2::plotPCA(vsd, intgroup="group") # plots the PCA to see if samples from same group have similar gene expression profiles



# 6. Differential expression analysis results
# Blood treatment vs control
res_blood <- DESeq2::results(dds, independentFiltering=FALSE, cooksCutoff=FALSE, 
                             contrast = c("group","Blood_WT_Case","Blood_WT_Control"))
res_blood <- na.omit(res_blood) # remove genes with NAs
res_blood <- res_blood[which(res_blood$padj < 0.01),] # Blood DE genes with adjusted p-value < 0.05
up_res_blood <- res_blood[which(res_blood$log2FoldChange > 0),] # Blood DE up-regulated genes in case relative to control
down_res_blood <- res_blood[which(res_blood$log2FoldChange < 0),] # Blood DE down-regulated genes in case relative to control
print(paste("There are", nrow(res_blood), "DE genes in blood tissues with", nrow(up_res_blood), "up-regulated vs", 
            nrow(down_res_blood), "down-regulated genes in treatments relative to control.")) 

# Lung treatment vs control
res_lung <- DESeq2::results(dds, independentFiltering=FALSE, cooksCutoff=FALSE, 
                            contrast = c("group","Lung_WT_Case","Lung_WT_Control"))
res_lung <- na.omit(res_lung) # remove genes with NAs
res_lung <- res_lung[which(res_lung$padj < 0.01),] # Lung DE genes with adjusted p-value < 0.05
up_res_lung <- res_lung[which(res_lung$log2FoldChange > 0),] # Lung DE up-regulated genes in case relative to control
down_res_lung <- res_lung[which(res_lung$log2FoldChange < 0),] # Lung DE down-regulated genes in case relative to control
print(paste("There are", nrow(res_lung), "DE genes in lung tissues with",nrow(up_res_lung), "up-regulated vs",
            nrow(down_res_lung), "down-regulated genes in treatments relative to control."))

# Look at the top most interesting genes with smallest padj values, search the genes corresponding to ENSMBL ID.
res_blood[which(res_blood$padj < 10^-200),]
res_lung[which(res_lung$padj < 10^-200),]



# 7. Over-representation analysis
library(clusterProfiler)
library(org.Mm.eg.db) # Genome wide association package for mouse species
# get the ENSEMBL IDs of DE genes
gene_blood <- row.names(res_blood)
gene_lung <- row.names(res_lung)

# Start the Over-representation analyses in blood and lung separately
ego_blood <- clusterProfiler::enrichGO(gene = gene_blood, 
                                       universe = names(dds), 
                                       OrgDb = org.Mm.eg.db, 
                                       ont = "ALL",
                                       keyType = "ENSEMBL",
                                       pAdjustMethod = "BH",
                                       pvalueCutoff = 0.01,
                                       qvalueCutoff = 0.05,
                                       readable = TRUE)
ego_lung <- clusterProfiler::enrichGO(gene = gene_lung, 
                                      universe = names(dds), 
                                      OrgDb = org.Mm.eg.db, 
                                      ont = "ALL",
                                      keyType = "ENSEMBL",
                                      pAdjustMethod = "BH",
                                      pvalueCutoff = 0.01,
                                      qvalueCutoff = 0.05,
                                      readable = TRUE)
# top GO terms can be looked within the header of those analyses and as tables
head(ego_blood)
head(ego_lung)

# Vizualisation of enrichment results for top GOterms
library(enirchplot)
library(ggplot2)
library(ggnewscale)
library(cowplot)
# Barplots
cowplot::plot_grid(barplot(ego_blood, showCategory = 20),
                   barplot(ego_lung, showCategory = 20), 
                   labels = c("Blood tissues", "Lung tissues"))
# Dotplots
cowplot::plot_grid(dotplot(ego_blood, showCategory = 20) + ggtitle("Dotplot for Blood tissues"),
                   dotplot(ego_lung, showCategory = 20)+ ggtitle("Dotplot for Lung tissues"))

# Enrichment map
emap_blood <- enrichplot::pairwise_termsim(ego_blood)
emapplot(emap_blood, layout="kk")
emap_lung <- enrichplot::pairwise_termsim(ego_lung)
emapplot(emap_lung, layout="kk")
