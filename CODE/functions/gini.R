# function to calculate the normalized gini coeficient
gini <- function(p,y, plot=FALSE){
    sorted <- cbind(p,y)
    y.val <- sum(y)
    sorted <- cbind(sorted[order(-p),-1],c(1:y.val,rep(y.val,nrow(sorted)-y.val)))
    sorted <- cbind(sorted,cumsum(sorted[,1]))
    sorted <- cbind(sorted,cumsum(rep(y.val/length(y),length(y))))
    csum <- colSums(sorted[,2:4])
    gini <- (csum[2]-csum[3])/(csum[1]-csum[3])
    
    if (plot){
        plot(
            x=1:nrow(sorted)/nrow(sorted),
            y=sorted[,3]/y.val,
            main="Cummulative Captured",
            xlab="% Investigated",
            ylab="% Captured")
        lines(x=1:nrow(sorted)/nrow(sorted),y=sorted[,2]/y.val)
        text(x=0.8,y=0.2,labels=paste("Gini: ",round(gini*100,1),"%",sep=""))
        
    }
    gini
}
