% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mergeEset.R
\name{mergeEset}
\alias{mergeEset}
\title{Merge two eSets by column binding}
\usage{
mergeEset(eset1, eset2, by.x, by.y, normalization = "quantile")
}
\arguments{
\item{eset1}{An \code{eSet} object}

\item{eset2}{Another \code{eSet} object}

\item{by.x}{Column index of feature annotation of \code{eset1}}

\item{by.y}{COlumn index of feature annotation of \code{eset2}}

\item{normalization}{\code{NULL} or character string, which will be passed to normalizeBetweenArrays.}
}
\value{
A new \code{eSet} object
}
\description{
Merge two eSets by column binding
}
