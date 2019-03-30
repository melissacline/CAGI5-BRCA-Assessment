library(ggplot2)
require(gridExtra)
setEPS()

postscript(file="../output/summary.stats.barcharts.eps")
as = read.table("../data/assessment.stats.sorted.txt", header=T, sep='\t')

#
# Give each predictor a color, based on alphabetical ordering of the
# method name
as$color = rainbow(nrow(as))[order(as$X)]

#
# Make AUC Barplot
pp1<- ggplot(as, aes(x=reorder(X, auc.Mean), y=auc.Mean, fill=X)) +
    geom_bar(stat="identity", color="black",   position=position_dodge()) +
             coord_flip() + scale_fill_manual(values=as$color) + guides(fill=FALSE) +
    geom_errorbar(aes(ymin=auc.Mean-auc.SD, ymax=auc.Mean+auc.SD), width=.2,
                 position=position_dodge(.9)) +
    labs(title="", x="", y = "Area Under ROC")+
         theme(axis.title.x = element_text(size=12),
	       axis.text = element_text(size=9),
               axis.title.y = element_blank())

#
# Make AUPR Barplot
pp2<- ggplot(as, aes(x=reorder(X, aupr.Mean), y=aupr.Mean, fill=X)) +
    geom_bar(stat="identity", color="black",   position=position_dodge()) +
             coord_flip() + scale_fill_manual(values=as$color) + guides(fill=FALSE) +
    geom_errorbar(aes(ymin=aupr.Mean-aupr.SD, ymax=aupr.Mean+aupr.SD), width=.2,
                 position=position_dodge(.9)) +
    labs(title="", x="", y = "Area Under Precision Recall")+
         theme(axis.title.x = element_text(size=12),
	       axis.text = element_text(size=9),
               axis.title.y = element_blank())

#
# Make precision barplot
pp3<- ggplot(as, aes(x=reorder(X, prec.Mean), y=prec.Mean, fill=X)) +
    geom_bar(stat="identity", color="black",   position=position_dodge()) +	
             coord_flip() + scale_fill_manual(values=as$color) + guides(fill=FALSE) +
    geom_errorbar(aes(ymin=prec.Mean-prec.SD, ymax=prec.Mean+prec.SD), width=.2,
                 position=position_dodge(.9)) +
    labs(title="", x="", y = "Precision")+
         theme(axis.title.x = element_text(size=12),
	       axis.text = element_text(size=9),
               axis.title.y = element_blank())

#
# Make recall barplot
pp4<- ggplot(as, aes(x=reorder(X, rec.Mean), y=rec.Mean, fill=X)) +
    geom_bar(stat="identity", color="black",   position=position_dodge()) +
             coord_flip() + scale_fill_manual(values=as$color) + guides(fill=FALSE) +
    geom_errorbar(aes(ymin=rec.Mean-rec.SD, ymax=rec.Mean+rec.SD), width=.2,
                 position=position_dodge(.9)) +
    labs(title="", x="", y = "Recall")+
         theme(axis.title.x = element_text(size=12),
	       axis.text = element_text(size=9),
               axis.title.y = element_blank())
grid.arrange(pp1,pp2,pp3,pp4,ncol=2)
dev.off()