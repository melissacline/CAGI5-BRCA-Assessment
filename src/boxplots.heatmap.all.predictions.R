library(RColorBrewer)
setEPS()

#
# Read the labeled predictions.  Remove the Class 3 variants.  Make a new
# column that labels the variants as pathogenic or benign.
pm = read.table("../data/predictions.merged.labeled.txt", header=T, sep="\t")
pm = subset(pm, Class != 3)
pm$Interpretation[which(pm$Class < 3)] = "Benign"
pm$Interpretation[which(pm$Class > 3)] = "Pathogenic"
pm$Interpretation = as.factor(pm$Interpretation)
predictorFrame = data.frame("Interpretation" = pm$Interpretation)
predictorFrame["Class"] = pm$Class

#
# Identify the prediction columns (the probabilities).  Derive a sorted list of those columns
predictorColumns = c()
predictorLabels = c()
for (ii  in 1:ncol(pm)) {
    if (length(grep("_P$", colnames(pm)[ii])) > 0) {
        predictorColumns = c(predictorColumns, ii)
        predictorLabels = c(predictorLabels, colnames(pm)[ii])
    }
}

#
# Build a new data frame that contains only the interpretation and the  
# predicted probabilities, with human-readable method names.
for (jj in order(predictorLabels)) {
    colIndex = predictorColumns[jj]
    colName = gsub("_", " ", sub("_P$", "", colnames(pm)[colIndex]))
    predictorFrame$new = pm[,colIndex]
    colnames(predictorFrame)[ncol(predictorFrame)] = colName
}

#
# Now generate the boxplots
colorPerMethod = rainbow(length(predictorLabels))
postscript(file="../output/Supplemental_Figure_1.eps")
par(mfrow=c(6,3),mar = c(2,3,2,1))
for (ii in 3:ncol(predictorFrame)) {
    boxplot(predictorFrame[,ii] ~ pm$Interpretation, 
            main=colnames(predictorFrame)[ii], 
            col=colorPerMethod[ii-2])
}
dev.off()

#
# Generate boxplots that relate predictions to the ENIGMA class (1-5)
postscript(file="../output/Supplemental_Figure_2.eps")
par(mfrow=c(6,3),mar = c(2,3,2,1))
for (ii in 3:ncol(predictorFrame)) {
    boxplot(predictorFrame[,ii] ~ pm$Class,,
            main=colnames(predictorFrame)[ii],
            col=colorPerMethod[ii-2])
}
dev.off()

#
# Build a special boxplot diagram for the TBI prediction
postscript(file="../output/Figure_3.eps")
par(mfcol=c(2,2), mar=c(2,3,2,1))
boxplot(TBI_1_P ~ Interpretation, data=pm, 
        main="TBI 1: Splicing, NN",
	col="blue")
boxplot(TBI_2_P ~ Interpretation, data=pm, 
        main="TBI 2: Splicing, MLR",
	col="green")
boxplot(TBI_3_P ~ Interpretation, data=pm, 
        main="TBI 3: No Splicing, NN",
	col="purple")
boxplot(TBI_4_P ~ Interpretation, data=pm, 
        main="TBI 4: No Splicing, MLR",
	col="cyan")
dev.off()



#
# Build a heatmap
# Slice off the interpretation column, and replace the NA values with -1
interpretation = predictorFrame$Interpretation
predictorFrame$Interpretation = NULL
predictorFrame[is.na(predictorFrame)] = -1
postscript(file="../output/Figure_1.eps")
heatmap(t(as.matrix(predictorFrame)), scale="none", labCol=NA,
        margins=c(12,9),
        ColSideColors=brewer.pal(3, "Paired")[as.factor(interpretation)])
dev.off()