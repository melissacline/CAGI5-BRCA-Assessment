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

pp1<- ggplot(as, aes(x=reorder(X, auc), y=auc, fill=X)) +
    geom_bar(stat="identity", color="black",   position=position_dodge()) +
             coord_flip() + scale_fill_manual(values=as$color) + guides(fill=FALSE) +
    geom_errorbar(aes(ymin=pmax(0,auc-auc.SD), ymax=pmin(1, auc+auc.SD)),
                  width=.2, position=position_dodge(.9)) +
    labs(title="", x="", y = "Area Under ROC")+
         theme(axis.title.x = element_text(size=12),
	       axis.text = element_text(size=9),
               axis.title.y = element_blank())

#
# Make AUPR Barplot
pp2<- ggplot(as, aes(x=reorder(X, aupr), y=aupr, fill=X)) +
    geom_bar(stat="identity", color="black",   position=position_dodge()) +
             coord_flip() + scale_fill_manual(values=as$color) + guides(fill=FALSE) +
    geom_errorbar(aes(ymin=pmax(0,aupr-aupr.SD), ymax=pmin(1,aupr+aupr.SD)),
    		  width=.2,position=position_dodge(.9)) +
    labs(title="", x="", y = "Area Under Precision Recall")+
         theme(axis.title.x = element_text(size=12),
	       axis.text = element_text(size=9),
               axis.title.y = element_blank())

#
# Make precision barplot
pp3<- ggplot(as, aes(x=reorder(X, prec), y=prec, fill=X)) +
    geom_bar(stat="identity", color="black",   position=position_dodge()) +	
             coord_flip() + scale_fill_manual(values=as$color) + guides(fill=FALSE) +
    geom_errorbar(aes(ymin=pmax(0,prec-prec.SD), ymax=pmin(1,prec+prec.SD)),
                  width=.2,position=position_dodge(.9)) +
    labs(title="", x="", y = "Precision")+
         theme(axis.title.x = element_text(size=12),
	       axis.text = element_text(size=9),
               axis.title.y = element_blank())

#
# Make recall barplot
pp4<- ggplot(as, aes(x=reorder(X, rec), y=rec, fill=X)) +
    geom_bar(stat="identity", color="black",   position=position_dodge()) +
             coord_flip() + scale_fill_manual(values=as$color) + guides(fill=FALSE) +
    geom_errorbar(aes(ymin=pmax(0,rec-rec.SD), ymax=pmin(rec+rec.SD)),
                 width=.2, position=position_dodge(.9)) +
    labs(title="", x="", y = "Recall")+
         theme(axis.title.x = element_text(size=12),
	       axis.text = element_text(size=9),
               axis.title.y = element_blank())
grid.arrange(pp1,pp2,pp3,pp4,ncol=2)
dev.off()