#!/usr/bin/env python
#
# Merge the actual assessments of the CAGI data, along with each of the 
# predictions, to create one large table of data with all predictions
# and the clinical interpretations of each variant.
#

import argparse
import csv
import glob
import numpy
import random
import re

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-a", "--actual", help="actual data",
                    default="../data/actual/CAGI_megamultifac_2018-06-01.txt")
    parser.add_argument("-f", "--full_set", default=False,
                        help="Full prediction set (including unpredicted)")
    parser.add_argument("-p", "--predictions", help="Predictions",
                        default="../data/prediction")
    args = parser.parse_args()

    actualData = readActualData(args.actual)
    predictedData = readPredictions(args.predictions)
    printData(actualData, predictedData, printFullSet=args.full_set)

def classToProbability(numericClass, addNoise=False):
    """
    Convert a numeric class to the midpoint of the corresponding
    probability range, as defined by the ENIGMA classification scheme.
    Optionally, add a small bit of random noise, not enough to alter the
    class.
    """
    classToProbVector = (0.025, 0.025, 0.5, 0.975, 0.975)
    randomNoiseMax = (0.024, 0.024, 0.2, 0.024, 0.024)
    assert(numericClass >= 1 and numericClass <= len(classToProbVector)+1)
    if addNoise:
        randomNoise = random.uniform(-1 * randomNoiseMax[numericClass - 1],
                                      randomNoiseMax[numericClass - 1])
        return(classToProbVector[numericClass-1] + randomNoise)
    else:
        return(classToProbVector[numericClass-1])



def readActualData(actualDataFilename):
    """
    Read the actual clinical interpretatins.  Return a dictionary that
    contains the numeric class (1 - 5) and a corresponding probability
    for each variant.  The keys of the dictionary are the gene symbol and
    HGVS nucleotide string joined with a colon, e.g. 'BRCA1:c.1036C>T'
    """
    variants = dict()
    fp = open(actualDataFilename)
    headerLine = fp.readline()  # skip header line
    for line in fp:
        tokens = line.rstrip().split('\t')
        variant = tokens[0] + ":" + tokens[1]
        varData = { "Assessment" : classToProbability(int(tokens[6])), 
                    "Class": tokens[6],
                    "ProteinHgvs": tokens[2]}
        variants[variant] = varData
    return(variants)



def readPredictions(predictionsDir):
    """
    Read each of the sets of predictions.  For each variant, return a 
    dictionary with dictionaries of each of the predictions by all predictors
    """
    predictions = dict()
    predictors = sorted(glob.glob(predictionsDir + "/*"))
    for thisPredictor in predictors:
        thesePredictions = readThisPredictionSet(thisPredictor)
        predictions = appendPredictions(predictions, thesePredictions)
    return(predictions)


def readThisPredictionSet(predictor):
    """
    Read each of the predictions from a given predictor.  Returns 
    a dictionary for which the key is the variant and the value is 
    a list of the predictions by this predictor.
    """
    predictions = dict()
    setCounter = 1
    vepLabels = ["polyphen", "revel", "sift"]
    for predictionFile in sorted(glob.glob(predictor + "/*prediction*txt")):
        #
        # The VEP 'predictor' is a special case for which we want the 
        # sets labeled by the method name.  For all other predictors,
        # label the prediction set according to a set counter.
        if re.search("VEP", predictor):
            setLabel = vepLabels[setCounter - 1]
        else:
            setLabel = str(setCounter)
        #print "predictionFile", predictionFile, "set", setLabel
        thesePredictions = readPredictionSet(predictionFile, predictor, 
                                             setLabel)
        predictions = appendPredictions(predictions, thesePredictions)
        setCounter += 1
    return(predictions)


def representsFloat(s):
    "This boolean function indicates whether the input is a float"
    try: 
        float(s)
        return True
    except ValueError:
        return False


def readPredictionSet(predictionFile, predictorDir, set, verbose=True):
    """
    Read a single set of predictions. Verify that the prediction data
    meets the expected format, and falls within the expected ranges.
    Return the estimated probability and SD per variant in a dictionary
    of dictionaries. for which the key is the variant name 
    (gene symbol : cDNA HGVS)
    """
    predictions = dict()
    label = "%s_Set_%s" % (re.split("/", predictorDir)[-1], set)
    pLabel = label + "_P"
    sdLabel = label + "_SD"
    fp = open(predictionFile)
    fp.readline()
    for line in fp:
        tokens = line.rstrip().split('\t')
        #
        # Verify that the data is formatted correctly
        assert(len(tokens) >= 5)
        assert(re.search("c.", tokens[0]))
        assert(tokens[1] == "BRCA1" or tokens[1] == "BRCA2")
        #
        # Assemble a key to identify the variant. The key consists of
        # the gene symbol and the cDNA HGVS string, separated by a colon.
        # Verify that there are only one set of results per variant.
        thisVariant = tokens[1] + ":" + tokens[0]
        assert(predictions.has_key(thisVariant) == False)
        #
        # Group 3 is a special case.  Rather than submitting probabilities,
        # they submitted classes (1-5).  Given their class predictions, 
        # convert them to probabilities, adding a small amount of random
        # noise to facilitate interpretation later
        if re.search("Group_3", predictorDir):
            thisP = classToProbability(int(tokens[3]), addNoise=True)
            #print predictorDir, "set", set, "filename", predictionFile, "variant", tokens[0], "prediction", tokens[3], "prob", thisP
        else:
            thisP = tokens[3]
        thisSD = tokens[4]
        if representsFloat(thisP) and representsFloat(thisSD):
            #
            # Verify that the data falls within the expected range.
            assert(float(thisP) >= 0.0 and float(thisP) <= 1.0)
            assert(float(thisSD) >= 0.0)
            predictions[thisVariant] = { pLabel:thisP, sdLabel:thisSD } 
    return(predictions)


def appendPredictions(predictions, newPredictions):
    """
    Given a new set of predictions, merge them into the current set.
    The set of predictions for each variant is represented by a dictionary.
    Collectively, the variants are represented as a dictionary of dictionaries.
    """
    for variant in newPredictions.keys():
        if not predictions.has_key(variant):
            predictions[variant] = newPredictions[variant]
        else:
            for key in newPredictions[variant].keys():
                predictions[variant][key] = newPredictions[variant][key]
    return predictions
        

def appendHeaders(headers, newHeaders):
    """Add a set of new headers to the existing set"""
    headers += newHeaders
    return headers


def printHeader(actualDataColnames, predictedDataColnames):
    """
    Print out the header line, with: the variant, the actual data,
    the predictions, and the median prediction probability.
    the prediction data.
    """
    print "Variant\t",
    print '\t'.join(actualDataColnames),
    print "\t",
    print '\t'.join(predictedDataColnames),
    print "\tMedianPrediction"


def printData(actualData, predictedData, printFullSet=False):
    """
    For each variant, print the variant name, the values from the 
    actual data dictionary, and the values from the predicted data
    dictionary, and the median probabiility from all predictors.  
    Order the values by sorted order of the column name,
    using the first variant in the set as an exemplar.
    """
    if printFullSet:
        variantSet = actualData.keys()
    else:
        variantSet = predictedData.keys()
    actualDataHeaders = sorted(actualData[variantSet[0]].keys())
    predictedDataHeaders =  sorted(predictedData[variantSet[0]].keys())
    printHeader(actualDataHeaders, predictedDataHeaders)
    for variant in variantSet:
        allPredictedProbabilities = list()
        print variant,
        for column in actualDataHeaders:
            print "\t%s" % (actualData[variant][column]),
        for column in predictedDataHeaders:
            if not predictedData.has_key(variant):
                print '\t',
            else:
                if predictedData[variant].has_key(column):
                    value = predictedData[variant][column]
                    print "\t%s" % (value),
                    #
                    # If this column is an estimated probability, 
                    # denoted by a label ending with a '_P', add
                    # the numeric value to the list.
                    if re.search("_P$", column) and value != "NA":
                        allPredictedProbabilities.append(float(value))
                else:
                    print '\t',
        if len(allPredictedProbabilities) > 0:
            print "\t%4.3f" % (numpy.median(allPredictedProbabilities))
        else:
            print
                              

if __name__ == "__main__":
    main()


