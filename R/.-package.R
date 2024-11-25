

#' Simulated survey design
#' 
#' Simulated survey design to show how the package works.
#' 
#' 
#' @name svy.exrep
#' @docType data
#' @format Survey Design
#' @source Simulation
#' @keywords datasets
NULL





#' Use survey designs including plausible values
#' 
#' This package was built to properly estimate various statistics (mean,
#' variance, glm \ldots) for survey designs which include plausible values.
#' Plausible values are random draws from a posterior density and are typically
#' used to make comparisons on the group level (this is typical for large scale
#' assessment data as PISA, PIAAC etc.).
#' 
#' \tabular{ll}{ Package: \tab svyPVpack\cr Type: \tab Package\cr Version: \tab
#' 0.1-1\cr Date: \tab 2014-03-06\cr License: \tab GPL (>=2) \cr }
#' 
#' @name svyPVpack-package
#' @aliases svyPVpack-package svyPVpack
#' @docType package
#' @author Manuel Reif <Manuel.Reif@@statistik.gv.at>, Jakob Peterbauer
#' <Jakob.Peterbauer@@statistik.gv.at>
#' 
#' Maintainer: Manuel Reif <Manuel.Reif@@statistik.gv.at>
#' @seealso \code{\link{svyPVglm}} \code{\link{svyPVpm}}
#' @references
#' 
#' Saerndal, C.-E. & Swensson, B. & Wretman, J. (1992). \emph{Model Assisted
#' Survey Sampling}. New York: Springer.
#' 
#' See also:
#' 
#' OECD (2013). \emph{Technical Report of the Survey of Adult Skills (PIAAC)}.
#' Retrieved from:
#' http://www.oecd.org/site/piaac/All\%20PIACC\%20Technical\%20Report\%20final.pdf
#' @keywords package
#' @examples
#' 
#' 
#' 
#' data(svy_example1)
#' 
#' erg_ben <- svyPVbenchmark(by = ~ sex, svydat=svy.exrep,
#' pvs=c("plaus1","plaus2","plaus3"), BENCH=320)
#' 
#' erg_ben
#' 
#' 
#' 
NULL



