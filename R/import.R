#' Read an expression matrix into an ExpressionSet object
#' 
#' The function reads in an expression matrix into an ExpressionSet object. The
#' expression matrix should be saved in the file format supported by the
#' \code{\link{read_exprs_matrix}} function: currently supported formats
#' include tab-delimited file and gct files.
#' 
#' The function is a wrapper of the \code{\link{read_exprs_matrix}} function in
#' the \code{ribiosIO} package. The difference is it returns a valid
#' \code{ExpressionSet} object instead of a primitive matrix.
#' 
#' @param x A file containing an expression matrix
#' @return An \code{ExpressionSet} object holding the expression matrix. Both
#' pData and fData are empty except for the feature/sample names recorded in
#' the expression matrix.
#' @author Jitao David Zhang <jitao_david.zhang@@roche.com>
#' @seealso \code{\link{read_exprs_matrix}} in the \code{ribiosIO} package.
#' @examples
#' 
#' idir <- system.file("extdata", package="ribiosExpression")
#' myeset <- readExprsMatrix(file.path(idir, "sample_eset_exprs.txt"))
#' myeset2 <- readExprsMatrix(file.path(idir, "test.gct"))
#' 
#' @importFrom ribiosIO read_exprs_matrix
#' @export readExprsMatrix
readExprsMatrix <- function(x) {
  exp <- read_exprs_matrix(x)
  res <- new("ExpressionSet",
             exprs=exp,
             phenoData=new("AnnotatedDataFrame",
               data.frame(row.names=colnames(exp))),
             featureData=new("AnnotatedDataFrame",
               data.frame(row.names=rownames(exp))))
  return(res)
}

#' Import ChipFetcher export files into an ExpressionSet object.
#' 
#' Import files exported by Roche web-tool \code{ChipFetcher} into an
#' \code{ExpressionSet} object.
#' 
#' \code{chip} and \code{orthologue} are only valid when
#' \code{ribiosAnnotation} is available.
#' 
#' @param filename Exported file name of ChipFetcher
#' @param chip Chip type used to annotate the features, e.g.
#' \code{HG-U133_PLUS_2}. In case missing, chips are automatically mapped.
#' Assigning the value of \code{chip} accelerates the probe mapping step.
#' @param orthologue Logical, whether features should be mapped to human
#' orthologues? By default \code{FALSE}.
#' @return An \code{ExpressionSet} object.
#' @author Jitao David Zhang <jitao_david.zhang@@roche.com>
#' @references \url{http://bioinfo.bas.roche.com:8080/bicgi/chipfetcher}
#' @importFrom utils read.csv read.table
#' @importFrom ribiosAnnotation annotateProbesets
#' @importFrom methods new
#' @importClassesFrom Biobase ExpressionSet AnnotatedDataFrame
#' @export ChipFetcher2ExpressionSet
ChipFetcher2ExpressionSet <- function(filename,
                                      chip,
                                      orthologue=FALSE) {
  if(missing(chip)) chip <- ""
  
  pre.scan <- scan(filename, what="character", sep="\n", nmax=200L, quiet=TRUE)
  probe.start <- grep("^[0-9]", pre.scan)[1L]
  ## in case probes do not have the name starting with [0-9]:
  ##    we rely on the line "is_Scalebase" to be the last line of phenotype
  ##    but is_Scalebase is not found either, we stop the function reporting an error (which should be fixed later)
  if(is.na(probe.start)) {
    scale.start <- grep("is_Scalebase", pre.scan)[1L]
    haltifnot(!is.na(scale.start),
              msg="The function can not detect where the expression matrix starts. Nor can it find a line starting with is_Scalebase. Please report the error to the developer")
    probe.start <- scale.start + 1L
  }
  ncols <- length(strsplit(pre.scan[probe.start],"\t")[[1L]])
  
  pheno.last.line <- probe.start - 1L
  pdata <- read.csv(filename, sep="\t", nrows=pheno.last.line-1L, row.names=1L)
  pheno.data.frame <- data.frame(t(pdata))

  rm(pdata, pre.scan, probe.start)
  
  exprs.matrix <- read.table(filename, skip=pheno.last.line,
                             row.names=1L,
                             colClasses=c("character", rep("numeric", ncols-2L)),
                             sep="\t", comment.char="")
  exprs.matrix <- data.matrix(exprs.matrix)
  feature.names <- rownames(exprs.matrix)

  feature.data.frame <- ribiosAnnotation::annotateProbesets(feature.names, chip, orthologue=orthologue)

  colnames(exprs.matrix) <- rownames(pheno.data.frame)
  
  expSet <- new("ExpressionSet",
                exprs=exprs.matrix,
                phenoData=new("AnnotatedDataFrame", pheno.data.frame),
                featureData=new("AnnotatedDataFrame", feature.data.frame))
  annotation(expSet) <- chip
  rm(exprs.matrix, pheno.data.frame, feature.data.frame)
  gc(reset=TRUE)
  return(expSet)
}


## import partek files
partek2ExpressionSet <- function(filename,
                                 chip,
                                 orthologue=FALSE) {
  if(missing(chip)) chip <- ""
  
  raw <- read.csv(filename, sep="\t")
  rawt <- t(raw)
  rm(raw)

  probeFmt <- "^ILMN"
  probeLns <- grep(probeFmt, rownames(rawt))
  if(length(probeLns)==0)
    stop("No probes found: currently only supporting Illumina data\n")
  probeStart <- min(probeLns)
  
  rp <- data.frame(t(rawt[1:probeStart-1L,]))
  raw.char <- rawt[probeStart:nrow(rawt),]
  raw.exp <- matrix(as.numeric(raw.char),
                    nrow=nrow(raw.char), ncol=ncol(raw.char), dimnames=dimnames(raw.char))
  if(requireNamespace("ribiosAnnotation")) {
    rf <- annotateProbesets(rownames(raw.exp), chip, orthologue=orthologue)
  } else {
    warning("ribiosAnnotation is not available. Features are not annotated")
  }
  eset <- new("ExpressionSet",
              exprs=raw.exp,
              featureData=new("AnnotatedDataFrame", rf),
              phenoData=new("AnnotatedDataFrame", rp))
  return(eset)
}
