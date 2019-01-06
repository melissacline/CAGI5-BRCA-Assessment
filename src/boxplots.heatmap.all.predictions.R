library(ggplot2)

#
# Read the labeled predictions.  Remove the Class 3 variants.  Make a new
# column that labels the variants as pathogenic or benign.
pm = read.table("../data/predictions.merged.labeled.txt", header=T, sep="\t")
pm = subset(pm, Class != 3)
pm$Interpretation[which(pm$Class < 3)] = "Benign"
pm$Interpretation[which(pm$Class > 3)] = "Pathogenic"
pm$Interpretation = as.factor(pm$Interpretation)
predictorFrame = data.frame("Interpretation" = pm$Interpretation)

#
# Identify the prediction columns (the probabilities).  Derive a sorted list of those columns
predictorColumns = c()
for (ii  in 1:ncol(pm)) {
    if (length(grep("_P$", colnames(pm)[ii])) > 0) {
        predictorColumns = c(predictorColumns, ii)
        predictorLabels = c(predictorLabels)
    }
}

#
# Build a new data frame that contains only the interpretation and the predicted 
# probabilities, with human-readable method names.
for (jj in order(predictorLabels)) {
    colIndex = predictorColumns[jj]
    colName = gsub("_", " ", sub("_P$", "", colnames(pm)[colIndex]))
    predictorFrame$new = pm[,colIndex]
    colnames(predictorFrame)[ncol(predictorFrame)] = colName
}

#
# Now generate the boxplots
colorPerMethod = rainbow(length(predictorLabels))
png(file="../output/boxplots.all.png", width=480, res=96)
par(mfrow=c(6,3),mar = c(2,3,2,1))
for (ii in 2:ncol(predictorFrame)) {
    boxplot(predictorFrame[,ii] ~ pm$Interpretation, main=colnames(predictorFrame)[ii], 
           col=colorPerMethod[ii-1])
}
dev.off()
