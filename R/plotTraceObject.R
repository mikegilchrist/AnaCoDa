# Plot functions for trace object
# The generic plot function expects the trace object
# and a string to the the function what has to be ploted.
# additional arguments are geneIndex, and category to index function like
# getExpressionTraceForGene or plotCodonSpecificParameters

#' Plot Trace Object
#' @param x An Rcpp trace object initialized with \code{initializeTraceObject}.
#' @param what A string containing one of the following to graph: \code{Mutation, Selection, Alpha, LambdaPrime, MeanWaitingTime, VarWaitingTime
#' MixtureProbability, Sphi, Mphi, Aphi, Spesilon, ExpectedPhi, Expression}.
#' @param geneIndex When plotting expression, the index of the gene to be plotted.
#' @param mixture The mixture for which to plot values.
#' @param ... Optional, additional arguments.
#' For this function, may be a logical value determining if the trace is ROC-based or not.
#'
#' @return This function has no return value.
#' 
#' @description Plots different traces, specified with the \code{what} parameter.
#'
plot.Rcpp_Trace <- function(x, what=c("Mutation", "Selection", "MixtureProbability" ,"Sphi", "Mphi", "Aphi", "Sepsilon", "ExpectedPhi", "Expression"), 
                                   geneIndex=1, mixture = 1, ...)
{
  if(what[1] == "Mutation")
  {
    plotCodonSpecificParameters(x, mixture, "Mutation", main="Mutation Parameter Traces")
  }
  if(what[1] == "Selection")
  {
    plotCodonSpecificParameters(x, mixture, "Selection", main="Selection Parameter Traces")
  }
  if(what[1] == "Alpha")
  {
    plotCodonSpecificParameters(x, mixture, "Alpha", main="Alpha Parameter Traces", ROC=FALSE)
  }
  if(what[1] == "LambdaPrime")
  {
    plotCodonSpecificParameters(x, mixture, "LambdaPrime", main="LambdaPrime Parameter Traces", ROC=FALSE)
  }  
  if(what[1] == "MeanWaitingTime")
  {
    plotCodonSpecificParameters(x, mixture, "MeanWaitingTime", main="Mean Waiting Time Parameter Traces", ROC=FALSE)
  }  
  if(what[1] == "VarWaitingTime")
  {
    plotCodonSpecificParameters(x, mixture, "VarWaitingTime", main="Variance Waiting Time Parameter Traces", ROC=FALSE)
  }  
  if(what[1] == "MixtureProbability")
  {
    plotMixtureProbability(x)
  }
  if(what[1] == "Sphi")
  {
    plotHyperParameterTrace(x, what = what[1]) 
  }
  if(what[1] == "Mphi") 
  {
    plotHyperParameterTrace(x, what = what[1])
  }
  if(what[1] == "Aphi")
  {
    plotHyperParameterTrace(x, what = what[1])
  }
  if(what[1] == "Sepsilon") 
  {
    plotHyperParameterTrace(x, what = what[1])
  }
  if(what[1] == "ExpectedPhi")
  {
    plotExpectedPhiTrace(x)
  }
  if(what[1] == "Expression")
  {
    plotExpressionTrace(x, geneIndex)
  }


}

# Called from Plot Trace Object (plot for trace)
# NOT EXPOSED
# 
#' Plot Codon Specific Parameter
#' @param trace An Rcpp trace object initialized with \code{initializeTraceObject}.
#'
#' @param mixture The mixture for which to plot values.
#'
#' @param type A string containing one of the following to graph: \code{Mutation, Selection, Alpha, LambdaPrime, MeanWaitingTime, VarWaitingTime}. 
#'
#' @param main The title of the plot.
#'
#' @param ROC A logical value determining if the Parameter was ROC or not.
#'
#' @return This function has no return value.
#' 
#' @description Plots a codon-specific set of traces, specified with the \code{type} parameter.
#'
plotCodonSpecificParameters <- function(trace, mixture, type="Mutation", main="Mutation Parameter Traces", ROC=TRUE)
{
  opar <- par(no.readonly = T) 
  
  ### Trace plot.
  if (ROC)
  {
    nf <- layout(matrix(c(rep(1, 4), 2:21), nrow = 6, ncol = 4, byrow = TRUE),
               rep(1, 4), c(2, 8, 8, 8, 8, 8), respect = FALSE)  
  }else
  {    
    nf <- layout(matrix(c(rep(1, 4), 2:25), nrow = 7, ncol = 4, byrow = TRUE),
                    rep(1, 4), c(2, 8, 8, 8, 8, 8, 8), respect = FALSE) 
  }
  ### Plot title.
  if (ROC){
    par(mar = c(0, 0, 0, 0))
  }else{
    par(mar = c(1,1,1,1))
  }
  plot(NULL, NULL, xlim = c(0, 1), ylim = c(0, 1), axes = FALSE)
  text(0.5, 0.6, main)
  text(0.5, 0.4, date(), cex = 0.6)
  par(mar = c(5.1, 4.1, 4.1, 2.1))
  
  # TODO change to groupList -> checks for ROC like model is not necessary!
  names.aa <- aminoAcids()
  with.ref.codon <- ifelse(ROC, TRUE, FALSE)
  
  for(aa in names.aa)
  { 
    codons <- AAToCodon(aa, with.ref.codon)
    if(length(codons) == 0) next
    if (!ROC){
      if(aa == "X") next
    }
    cur.trace <- vector("list", length(codons))
    paramType <- 0
    if(type == "Mutation"){
      ylab <- expression(Delta~"M")
      paramType <- 0
      special <- FALSE
    }else if (type == "Selection"){
      ylab <- expression(Delta~eta)
      paramType <- 1
      special <- FALSE
    }else if (type == "Alpha"){
      ylab <- expression(alpha)
      paramType <- 0
      special <- FALSE
    }else if (type == "LambdaPrime"){
      ylab <- expression(lambda~"'")
      paramType <- 1
      special <- FALSE
    }else if (type == "MeanWaitingTime"){
      ylab <- expression(alpha/lambda~"'")
      special <- TRUE
    }else if (type == "VarWaitingTime"){
      ylab <- expression(alpha/lambda~"'"^"2")
      special <- TRUE
    }else{
      stop("Parameter 'type' not recognized! Must be one of: 'Mutation', 'Selection', 'Alpha', 'LambdaPrime', 'MeanWaitingTime', 'VarWaitingTime'.")
    }

    for(i in 1:length(codons)){
      if(special){
        tmpAlpha <- trace$getCodonSpecificParameterTraceByMixtureElementForCodon(mixture, codons[i], 0, with.ref.codon)
        tmpLambdaPrime <- trace$getCodonSpecificParameterTraceByMixtureElementForCodon(mixture, codons[i], 1, with.ref.codon)
        
        if (type == "MeanWaitingTime"){          
          cur.trace[[i]] <- tmpAlpha / tmpLambdaPrime
        }else if (type == "VarWaitingTime"){
          cur.trace[[i]] <- tmpAlpha / (tmpLambdaPrime * tmpLambdaPrime)
        }
      }
      else{
        cur.trace[[i]] <- trace$getCodonSpecificParameterTraceByMixtureElementForCodon(mixture, codons[i], paramType, with.ref.codon)
      }
    }

    cur.trace <- do.call("cbind", cur.trace)
    if(length(cur.trace) == 0) next
    x <- 1:dim(cur.trace)[1]
    xlim <- range(x)
    ylim <- range(cur.trace, na.rm=T)
    
    main.aa <- aa #TODO map to three leter code
    plot(NULL, NULL, xlim = xlim, ylim = ylim,
         xlab = "Samples", ylab = ylab, main = main.aa)
    plot.order <- order(apply(cur.trace, 2, sd), decreasing = TRUE)
    for(i.codon in plot.order){
      lines(x = x, y = cur.trace[, i.codon], col = .codonColors[[codons[i.codon]]])
    }
    colors <- unlist(.codonColors[codons])
    legend("topleft", legend = codons, col = colors, 
           lty = rep(1, length(codons)), bty = "n", cex = 0.75)
  }
  par(opar)
} 

# Called from Plot Trace Object (plot for trace)
# NOT EXPOSED
# 
#' Plot Codon Specific Hyper Parameter
#' @param trace An Rcpp trace object initialized with \code{initializeTraceObject}.
#'
#' @param mixture The mixture for which to plot values.
#'
#' @param type A string containing one of the following to graph: \code{Random, LoglikelihoodRatio, currLoglikelihood, propLoglikelihood, currLoglikelihoodAdjusted, propLoglikelihoodAdjusted}. 
#'
#' @param main The title of the plot.
#'
#' @param PA A logical value determining if the Parameter was PA or not.
#'
#' @return This function has no return value.
#' 
#' @description Plots a codon-specific set of traces, specified with the \code{type} parameter.
#'
plotCodonSpecificHyperParameters <- function(trace, mixture, type="RandomNumber", main="Random Number Parameter Traces", PA=TRUE)
{
  opar <- par(no.readonly = T) 
  
  ### Trace plot.
  if (PA)
  {
    nf <- layout(matrix(c(rep(1, 4), 2:21), nrow = 6, ncol = 4, byrow = TRUE), rep(1, 4), c(2, 8, 8, 8, 8, 8), respect = FALSE)  
  }else
  {    
      return
  }
  ### Plot title.
  par(mar = c(1,1,1,1))
  
  plot(NULL, NULL, xlim = c(0, 1), ylim = c(0, 1), axes = FALSE)
  text(0.5, 0.6, main)
  text(0.5, 0.4, date(), cex = 0.6)
  par(mar = c(5.1, 4.1, 4.1, 2.1))
  
  names.aa <- aminoAcids()
  
  for(aa in names.aa)
  {
 	if(aa == "X") next
    
    codons <- AAToCodon(aa, FALSE)
    if(length(codons) == 0) next
 	cur.trace <- vector("list", length(codons))
    
 	  if(type == "RandomNumber"){
 	    ylab <- expression("Random Number")
 	    paramType <- 0
 	  }else if (type == "AcceptanceRatio"){
 	    ylab <- expression("Acceptance Ratio")
 	    paramType <- 1
 	  }else if (type == "CurrentLogLikelihood"){
 	    ylab <- expression("Current Log Likelihood")
 	    paramType <- 2
 	  }else if (type == "ProposedLogLikelihood"){
 	    ylab <- expression("Proposed Log Likelihood")
 	    paramType <- 3
 	  }else if (type == "CurrentLogLikelihoodAdjusted"){
 	    ylab <- expression("Adjusted Current Log Likelihood")
 	    paramType <- 4
 	  }else if (type == "ProposedLogLikelihoodAdjusted"){
 	    ylab <- expression("Adjusted Proposed Log Likelihood")
 	    paramType <- 5
 	  }else{
 	    stop("Parameter 'type' not recognized! Must be one of: 'Mutation', 'Selection', 'Alpha', 'LambdaPrime', 'MeanWaitingTime', 'VarWaitingTime'.")
      }
    
    for(i in 1:length(codons))
    { 
        cur.trace[[i]] <- trace$getCodonSpecificHyperParameterTraceByMixtureElementForCodon(mixture, codons[i], paramType)
    }
  
    

    cur.trace <- do.call("cbind", cur.trace)
    if(length(cur.trace) == 0) next
    x <- 1:dim(cur.trace)[1]
    xlim <- range(x)
    ylim <- range(cur.trace, na.rm=T)
    
    main.aa <- aa #TODO map to three leter code
    plot(NULL, NULL, xlim = xlim, ylim = ylim,
         xlab = "Samples", ylab = ylab, main = main.aa)
    plot.order <- order(apply(cur.trace, 2, sd), decreasing = TRUE)
    for(i.codon in plot.order){
      lines(x = x, y = cur.trace[, i.codon], col = .codonColors[[codons[i.codon]]])
    }
    colors <- unlist(.codonColors[codons])
    legend("topleft", legend = codons, col = colors, 
           lty = rep(1, length(codons)), bty = "n", cex = 0.75)
  }
  #par(opar)
  print(cur.trace)
} 

# NOT EXPOSED
plotExpressionTrace <- function(trace, geneIndex)
{
  plot(log10(trace$getSynthesisRateTraceForGene(geneIndex)), type= "l", xlab = "Sample", ylab = expression("log"[10]~"("~phi~")"))
}

# NOT EXPOSED
plotExpectedPhiTrace <- function(trace)
{
  par(mar=c(5,5,4,2))
  plot(trace$getExpectedSynthesisRateTrace()[-1], type="l", xlab = "Sample", ylab = expression(bar(phi)), 
       main = expression("Trace of the Expected value of "~phi))
  abline(h=1, col="red", lwd=1.5, lty=2)
}

# NOT EXPOSED
# Currently can only be one of Sphi, Mphi, Aphi, and Sepsilon.
plotHyperParameterTrace <- function(trace, what = c("Sphi", "Mphi", "Aphi", "Sepsilon"))
{
#  opar <- par(no.readonly = T) 
#  par(oma=c(1,1,2,1), mgp=c(2,1,0), mar = c(3,4,2,1), mfrow=c(2, 1))
  xlab <- "Sample"
  
  if (what[1] == "Sphi")
  {
    sphi <- trace$getStdDevSynthesisRateTraces();
    numMixtures <- length(sphi)
    sphi <- do.call("cbind", sphi)
    
    ylimit <- range(sphi) + c(-0.1, 0.1)
    xlimit <- c(1, nrow(sphi))
    ylab <- expression("s"[phi])
    main <- expression("s"[phi]*"Trace")
    plot(NULL, NULL, type="l", xlab = xlab, ylab = ylab, xlim = xlimit, ylim = ylimit, main = main)
    
    for(i in 1:ncol(sphi))
    {
      lines(sphi[-1,i], col = .mixtureColors[i])
    }
    legend("topleft", legend = paste0("Mixture Element", 1:numMixtures), 
           col = .mixtureColors[1:numMixtures], lty = rep(1, numMixtures), bty = "n")
  }
  else if (what[1] == "Mphi")
  {
    sphi <- trace$getStdDevSynthesisRateTraces();
    numMixtures <- length(sphi)
    sphi <- do.call("cbind", sphi)
    mphi <- -(sphi * sphi) / 2;

    ylimit <- range(mphi) + c(-0.1, 0.1)
    xlimit <- c(1, nrow(mphi))
    ylab <- expression("m"[phi])
    main <- expression("m"[phi]*"Trace")
    plot(NULL, NULL, type="l", xlab = xlab, ylab = ylab, xlim  = xlimit, ylim = ylimit, main = main)
    
    for(i in 1:ncol(mphi))
    {
      lines(mphi[-1,i], col= .mixtureColors[i])
    }
    legend("topleft", legend = paste0("Mixture Element", 1:numMixtures), 
           col = .mixtureColors[1:numMixtures], lty = rep(1, numMixtures), bty = "n")    

  }
  else if (what[1] == "Aphi") 
  {
    aphi <- trace$getSynthesisOffsetTrace();
    aphi <- do.call("cbind", aphi)
    
    ylimit <- range(aphi) + c(-0.1, 0.1)
    xlimit <- c(1, nrow(aphi))
    ylab <- expression("A"[phi])
    main <- expression("A"[phi]~"Trace")
    plot(NULL, NULL, type="l", xlab = xlab, ylab = ylab, xlim  = xlimit, ylim = ylimit, main = main)
    
    num.obs.data <- ncol(aphi)
    for(i in 1:num.obs.data)
    {
      lines(aphi[-1,i], col = .mixtureColors[i])
    }
    legend("topleft", legend = paste0("Observed Data", 1:num.obs.data), 
           col = .mixtureColors[1:num.obs.data], lty = rep(1, num.obs.data), bty = "n")        
  }
  else if (what[1] == "Sepsilon")
  {
    sepsilon <- trace$getObservedSynthesisNoiseTrace();
    sepsilon <- do.call("cbind", sepsilon)

    ylimit <- range(sepsilon) + c(-0.1, 0.1)
    xlimit <- c(1, nrow(sepsilon))
    ylab <- expression("s"[epsilon])
    main <- expression("s"[epsilon]~"Trace")
    plot(NULL, NULL, type="l", xlab = xlab, ylab = ylab, xlim  = xlimit, ylim = ylimit, main = main)

    num.obs.data <- ncol(sepsilon)
    for(i in 1:num.obs.data)
    {
      lines(sepsilon[-1,i], col = .mixtureColors[i])
    }
    legend("topleft", legend = paste0("Observed Data", 1:num.obs.data), 
           col = .mixtureColors[1:num.obs.data], lty = rep(1, num.obs.data), bty = "n")  
  }
  #par(opar)
}

# NOT EXPOSED
plotMixtureProbability <- function(trace)
{
  samples <- length(trace$getMixtureProbabilitiesTraceForMixture(1))
  numMixtures <- trace$getNumberOfMixtures()
  
  plot(NULL, NULL, xlim = c(0, samples), ylim=c(0, 1), xlab = "Samples", ylab = "Mixture Probability", main = "Mixture Probability")
  for (i in 1:numMixtures)
  {
    lines(trace$getMixtureProbabilitiesTraceForMixture(i)[-1], col = .mixtureColors[i])    
  }
  legend("topleft", legend = paste0("Mixture Element", 1:numMixtures), 
         col = .mixtureColors[1:numMixtures], lty = rep(1, numMixtures), bty = "n")
}
