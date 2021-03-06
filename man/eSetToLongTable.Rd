% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/transformations.R
\name{eSetToLongTable}
\alias{eSetToLongTable}
\title{Transform eSet to long data.frame}
\usage{
eSetToLongTable(
  x,
  exprsFun = function(eset) Biobase::exprs(eset),
  includeOtherAssayData = FALSE
)
}
\arguments{
\item{x}{An \code{eSet} object}

\item{exprsFun}{A function to extract expression values, by default \code{exprs}}

\item{includeOtherAssayData}{Logical, whether other elements in the \code{assayData} environment (if present) should be returned.

The function extracts exprs (and other values in the \code{assayData} environment), and return it in a long data.frame format with phenotypic data}
}
\description{
Transform eSet to long data.frame
}
\examples{
data(ribios.ExpressionSet, package="ribiosExpression")
exprsLongTbl <- eSetToLongTable(ribios.ExpressionSet)
seLongTbl <- eSetToLongTable(ribios.ExpressionSet, 
   exprsFun=function(eset) Biobase::assayData(eset)$se.exprs)
}
