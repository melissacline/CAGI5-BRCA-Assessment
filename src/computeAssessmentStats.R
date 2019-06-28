library(pROC)
library(ROCR)
library(PRROC)
library(stringr)


oneIterationPredictionScoring = function(realValue, realClass,
			      	         predictedValue, predictedValueStd,
					 addRandomNoise=F)
{
    if (addRandomNoise) {
        thisPredictedValue = predictedValue + rnorm(length(predictedValueStd),
                                                0, predictedValueStd)
    } else {
        thisPredictedValue = predictedValue
    }
    #get the correlation coefficients
    pearsonCor.coeff <- cor(realValue , thisPredictedValue , 
                            method = "pearson",  use="pairwise")

    #get RMSD
    nPredictions = length(thisPredictedValue) 
                           - sum(is.na(thisPredictedValue))
    rmsd = sum((thisPredictedValue - realValue)^2, na.rm=T)/nPredictions

    #
    # Get the AUC
    allValues = data.frame("class"=realClass,"prediction"=thisPredictedValue)
    aucStruct = performance(prediction(allValues$prediction,
				(allValues$class >= 4)),"auc")
    auc = round(unlist(slot(aucStruct, "y.values")), digits = 6)

    #
    # Get the area under the Precision/Recall curve
    allValues = subset(allValues, !is.na(prediction))
    pr = pr.curve(scores.class0=subset(allValues, class > 3)$prediction,
	          scores.class1=subset(allValues, class < 3)$prediction)
    aupr = unlist(pr$auc.integral)
	
    # 
    # Find the threshold that optimizes F1, and measure the
    # sensitivity, specificity, accuracy and F1 for that threshold.
    performance = findThresholdBestF1(allValues$prediction, 
	                              (allValues$class >= 4),
                                      seq(0,1,length.out=100))
    newResults = data.frame("rmsd"=signif(rmsd,3), 
                            "pearson.coeff"=signif(pearsonCor.coeff,3), 
                            "auc"=signif(auc,3),
	                    "aupr"=signif(aupr,3), 
			    "prec"=signif(performance$precision,3),
			    "rec"=signif(performance$recall,3),
	                    "acc"=signif(performance$accuracy,3),
		            "f1"=signif(performance$f1,3),
			    "threshold"=signif(performance$threshold,3))
    return(newResults)
}



scorePrediction = function(realValue, realClass, predictedValue, 
                           predictedValueStd, bootstrap.tests, method)
{
    nonBootstrapResults = oneIterationPredictionScoring(realValue, realClass,
                                    		        predictedValue,
							predictedValueStd,
				                        addRandomNoise=F)
    bootstrapResults = data.frame()                             
    for (jj in 1:bootstrap.tests) {
    	newResults = oneIterationPredictionScoring(realValue, realClass,
	                                           predictedValue,
						   predictedValueStd,
						   addRandomNoise=T)
        bootstrapResults = rbind(bootstrapResults, newResults)
    }
    sdVals = as.data.frame(t(apply(bootstrapResults, 2, sd)))
    colnames(sdVals) = paste(colnames(bootstrapResults), "SD")
    finalResults = cbind(nonBootstrapResults, sdVals)
    rownames(finalResults) = c(method)
    return(finalResults)
}


findThresholdBestF1 = function(predicted.value, actual.patho, thresholds) 
{
    f1 = thresholds * 0
    specificity = thresholds * 0
    sensitivity = thresholds * 0
    accuracy = thresholds * 0
    prec = thresholds * 0
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
	prec[ii] = TP / (TP + FP)
    }
    bestIndex = which.max(f1)
    return(data.frame("sensitivity" = sensitivity[bestIndex], 
                      "specificity"=specificity[bestIndex],
                      "accuracy"=accuracy[bestIndex],
		      "precision"=prec[bestIndex],
		      "recall"=sensitivity[bestIndex],
                      "f1"=f1[bestIndex],
		      "threshold"=thresholds[bestIndex]))
}

options(digits=3)
mp = read.table('../data/predictions.merged.labeled.txt', na.strings="NA", 
                header=T, fill=T)
results = data.frame()
#
# Combine all Pathogenic and Likely Pathogenic into one set, all Benign and
# Likely Benign into one set, and omit all VUS variants. 
mp[which(mp$Class ==4),]$Class = 5
mp[which(mp$Class ==2),]$Class = 1
mp = subset(mp, Class != 3)
realValue = mp$Assessment
for (ii in 1:length(mp)) {
    print(colnames(mp)[ii])
    if (length(grep("_P$", colnames(mp)[ii])) > 0) {
        predictedValue = mp[,ii]
        predictedValueStd = mp[,ii+1]
        predictedValueStd[is.na(predictedValueStd)] = 0
        newResults = scorePrediction(realValue, mp$Class,
                                 predictedValue, predictedValueStd,
                                 bootstrap.tests=10000,
                                 method=colnames(mp)[ii])
        if (nrow(results) == 0) {
            results = newResults
        } else {
            results = rbind(results, newResults)
        }
   }
}
colOrder = c('rmsd', 'rmsd SD', 'pearson.coeff', 'pearson.coeff SD',
	     'auc', 'auc SD', 'aupr', 'aupr SD',
	     'prec', 'prec SD', 'rec', 'rec SD', 
	     'acc', 'acc SD', 'f1', 'f1 SD', 'threshold')
write.table(results[,colOrder], file="../data/assessment.stats.txt", 
				col.names=NA,  row.names=T, sep='\t', quote=F)

