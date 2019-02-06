library(ggplot2)
setEPS()

as = read.table("../data/assessment.stats.sorted.txt", header=T, sep='\t')

#
# Give each predictor a color, based on alphabetical ordering of the
# method name
as$color = rainbow(nrow(as))[order(as$X)]

#
# Make AUC Barplot
postscript(file="../output/AUROC.eps")
pp<- ggplot(as, aes(x=reorder(X, auc.Mean), y=auc.Mean, fill=X)) +
    geom_bar(stat="identity", color="black",   position=position_dodge()) +
             coord_flip() + scale_fill_manual(values=as$color) + guides(fill=FALSE) +
    geom_errorbar(aes(ymin=auc.Mean-auc.SD, ymax=auc.Mean+auc.SD), width=.2,
                 position=position_dodge(.9)) +
    labs(title="", x="", y = "Area Under ROC")+
         theme(axis.title.x = element_text(size=20),
               axis.title.y = element_blank())
print(pp)
dev.off()

#
# Make AUPR Barplot
postscript(file="../output/AUPR.eps")
pp<- ggplot(as, aes(x=reorder(X, aupr.Mean), y=aupr.Mean, fill=X)) +
    geom_bar(stat="identity", color="black",   position=position_dodge()) +
             coord_flip() + scale_fill_manual(values=as$color) + guides(fill=FALSE) +
    geom_errorbar(aes(ymin=aupr.Mean-aupr.SD, ymax=aupr.Mean+aupr.SD), width=.2,
                 position=position_dodge(.9)) +
    labs(title="", x="", y = "Area Under Precision Recall")+
         theme(axis.title.x = element_text(size=20),
               axis.title.y = element_blank())
print(pp)
dev.off()

#
# Make precision barplot
postscript(file="../output/prec.eps")
pp<- ggplot(as, aes(x=reorder(X, prec.Mean), y=prec.Mean, fill=X)) +
    geom_bar(stat="identity", color="black",   position=position_dodge()) +	
             coord_flip() + scale_fill_manual(values=as$color) + guides(fill=FALSE) +
    geom_errorbar(aes(ymin=prec.Mean-prec.SD, ymax=prec.Mean+prec.SD), width=.2,
                 position=position_dodge(.9)) +
    labs(title="", x="", y = "Precision")+
         theme(axis.title.x = element_text(size=20),
               axis.title.y = element_blank())
print(pp)
dev.off()

#
# Make recall barplot
postscript(file="../output/rec.eps")
pp<- ggplot(as, aes(x=reorder(X, rec.Mean), y=rec.Mean, fill=X)) +
    geom_bar(stat="identity", color="black",   position=position_dodge()) +
             coord_flip() + scale_fill_manual(values=as$color) + guides(fill=FALSE) +
    geom_errorbar(aes(ymin=rec.Mean-rec.SD, ymax=rec.Mean+rec.SD), width=.2,
                 position=position_dodge(.9)) +
    labs(title="", x="", y = "Recall")+
         theme(axis.title.x = element_text(size=20),
               axis.title.y = element_blank())
print(pp)
dev.off()
