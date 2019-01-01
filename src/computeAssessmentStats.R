library(pROC)
library(ROCR)
library(stringr)



scorePrediction = function(realValue, realClass, predictedValue, 
                           predictedValueStd, bootstrap.tests, method)
{   
    allResults = data.frame()                             
    for (jj in 1:bootstrap.tests) {
        thisPredictedValue = predictedValue + rnorm(length(predictedValueStd),
                                                    0, predictedValueStd)
        #get the correlation coefficients
        pearsonCor.coeff <- cor(realValue , thisPredictedValue , 
                                method = "pearson",  use="pairwise")
        kendallCor.coeff <- cor(realValue , thisPredictedValue , 
                                method = "kendall", use="pairwise")

        #get RMSD
        nPredictions = length(thisPredictedValue) 
                           - sum(is.na(thisPredictedValue))
        rmsd = sum((thisPredictedValue - realValue)^2, na.rm=T)/nPredictions

        # get AUC
        mm = multiclass.roc(realClass, thisPredictedValue) 
        auc = as.numeric(mm$auc)

        # Omit the variants classified as Class 3
        allValues = data.frame("class"=realClass, 
                               "prediction"=thisPredictedValue)
        noVus = subset(allValues, class != 3)
        aucStruct.noVus = performance(prediction(noVus$prediction,
					         (noVus$class >= 4)),"auc")
        auc.noVus = round(unlist(slot(aucStruct.noVus, "y.values")), 
                          digits = 6)
        performance = findThresholdBestF1(noVus$prediction, (noVus$class >= 4),
                                          seq(0,1,length.out=100))
        newResults = data.frame("rmsd"=signif(rmsd,3), 
                         "pearson.coeff"=signif(pearsonCor.coeff,3), 
                         "kendall.coeff"=signif(kendallCor.coeff,3),
	                 "auc"=signif(auc,3), "auc.noVus"=signif(auc.noVus, 3),
	                 "sens.noVus"=signif(performance$sensitivity,3),
	                 "spec.noVus"=signif(performance$specificity,3),
	                 "acc.noVus"=signif(performance$accuracy,3),
		         "f1.noVus"=signif(performance$f1,3))
        allResults = rbind(allResults, newResults)
    }
    meanVals = as.data.frame(t(apply(allResults, 2, mean)))
    colnames(meanVals) = paste(colnames(allResults), "Mean")
    sdVals = as.data.frame(t(apply(allResults, 2, sd)))
    colnames(sdVals) = paste(colnames(allResults), "SD")
    finalResults = cbind(meanVals, sdVals)
    rownames(finalResults) = c(method)
    return(finalResults)
}


findThresholdBestF1 = function(predicted.value, actual.patho, thresholds) 
{
    f1 = thresholds * 0
    specificity = thresholds * 0
    sensitivity = thresholds * 0
    accuracy = thresholds * 0
    for (ii in 1:length(thresholds)) {
        this.threshold = thresholds[ii]
        pred.patho = (predicted.value >= this.threshold)
        TP = sum(pred.patho == actual.patho & actual.patho==T, na.rm=T)
        FN = sum(pred.patho != actual.patho & actual.patho==T, na.rm=T)
        TN = sum(pred.patho == actual.patho & actual.patho==F, na.rm=T)
        FP = sum(pred.patho != actual.patho & actual.patho==F, na.rm=T)
        sensitivity[ii] = TP / (TP + FN)
        specificity[ii] = TN / (TN + FP)
        accuracy[ii] = (TP + TN)/(TP + FP + FN +TN)
        f1[ii] = 2 * TP / (2 * TP + FP + FN)
    }
    bestIndex = which.max(f1)
    return(data.frame("sensitivity" = sensitivity[bestIndex], 
                      "specificity"=specificity[bestIndex],
                      "accuracy"=accuracy[bestIndex],
                      "f1"=f1[bestIndex]))
}

mp = read.table('../data/predictions.merged.txt', na.strings="NA", 
                header=T, fill=T)
results = data.frame()
realValue = mp$Assessment
#
# 
mp[which(mp$Class ==4),]$Class = 5
mp[which(mp$Class ==2),]$Class = 1
for (ii in 1:length(mp)) {
    print(colnames(mp)[ii])
    if (length(grep("_P$", colnames(mp)[ii])) > 0) {
        predictedValue = mp[,ii]
        predictedValueStd = mp[,ii+1]
        predictedValueStd[is.na(predictedValueStd)] = 0
        newResults = scorePrediction(realValue, mp$Class,
                                 predictedValue, predictedValueStd,
                                 bootstrap.tests=5,
                                 method=colnames(mp)[ii])
        if (nrow(results) == 0) {
            results = newResults
        } else {
            results = rbind(results, newResults)
        }
   }
}
write.table(results, file="assessment.stats.txt", col.names=NA, row.names=T,
            sep='\t', quote=F)
