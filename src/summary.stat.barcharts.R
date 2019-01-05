library(ggplot2)

as = read.table("../data/assessment.stats.txt", header=T, sep='\t')

#
# Give each predictor a color, based on alphabetical ordering of the
# method name
as$color = rainbow(nrow(as))[order(as$Method)]

#
# Make AUC Barplot
png(file="../output/AUC.png", width=480, res=96)
pp<- ggplot(as, aes(x=reorder(Method, auc.Mean), y=auc.Mean, fill=Method)) +
    geom_bar(stat="identity", color="black",   position=position_dodge()) +
             coord_flip() + scale_fill_manual(values=as$color) + guides(fill=FALSE) +
    geom_errorbar(aes(ymin=auc.Mean-auc.SD, ymax=auc.Mean+auc.SD), width=.2,
                 position=position_dodge(.9)) +
    labs(title="", x="", y = "AUC")+
         theme(axis.title.x = element_text(size=20),
               axis.title.y = element_blank())
print(pp)
dev.off()

#
# Make sensitivity barplot
png(file="../output/sens.png", width=480, res=96)
pp<- ggplot(as, aes(x=reorder(Method, sens.Mean), y=sens.Mean, fill=Method)) +
    geom_bar(stat="identity", color="black",   position=position_dodge()) +	
             coord_flip() + scale_fill_manual(values=as$color) + guides(fill=FALSE) +
    geom_errorbar(aes(ymin=sens.Mean-sens.SD, ymax=sens.Mean+sens.SD), width=.2,
                 position=position_dodge(.9)) +
    labs(title="", x="", y = "Sensitivity")+
         theme(axis.title.x = element_text(size=20),
               axis.title.y = element_blank())
print(pp)
dev.off()

#
# Make specificity barplot
png(file="../output/spec.png", width=480, res=96)
pp<- ggplot(as, aes(x=reorder(Method, spec.Mean), y=spec.Mean, fill=Method)) +
    geom_bar(stat="identity", color="black",   position=position_dodge()) +
             coord_flip() + scale_fill_manual(values=as$color) + guides(fill=FALSE) +
    geom_errorbar(aes(ymin=spec.Mean-spec.SD, ymax=spec.Mean+spec.SD), width=.2,
                 position=position_dodge(.9)) +
    labs(title="", x="", y = "Specificity")+
         theme(axis.title.x = element_text(size=20),
               axis.title.y = element_blank())
print(pp)
dev.off()

#
# Make Pearson Correlation barplots
png(file="../output/pearson.png", width=480, res=96)
pp<- ggplot(as, aes(x=reorder(Method, pearson.coeff.Mean), y=pearson.coeff.Mean, 
            fill=Method)) +
    geom_bar(stat="identity", color="black",   position=position_dodge()) +
             coord_flip() + scale_fill_manual(values=as$color) + guides(fill=FALSE) +
    geom_errorbar(aes(ymin=pearson.coeff.Mean-pearson.coeff.SD, 
    		      ymax=pearson.coeff.Mean+pearson.coeff.SD), width=.2,
                 position=position_dodge(.9)) +
    labs(title="", x="", y = "Pearson Correlation")+
         theme(axis.title.x = element_text(size=20),
               axis.title.y = element_blank())
print(pp)
dev.off()

