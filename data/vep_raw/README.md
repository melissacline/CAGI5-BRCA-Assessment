#
# VEP was used on 12/27/18 to gather SIFT, POLYPHEN and REVEL results for the
# prediction targets.  The file vep_input.txt was uploaded to the web 
# engine https://uswest.ensembl.org/Tools/VEP, and run with:
# - RefSeq transcripts database
# - Pathogenicity predictions: 
#   * SIFT: score only
#   * PolyPhen: score only 
#   * Condel: Enabled.  Fields to include: Revel_score
#   * Score/prediction: Score only
# - no other outputs selected
#
# The file vep_output.txt was downloaded from the results
# This file was preprocessed with the commands in src/vep_preprocess.bash
#
