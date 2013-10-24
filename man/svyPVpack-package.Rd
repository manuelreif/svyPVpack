\name{svyPVpack-package}
\alias{svyPVpack-package}
\alias{svyPVpack}
\docType{package}
\title{
Use survey designs including plausible values
}
\description{
This package was built to properly estimate various statistics (mean, variance, glm \ldots) for survey designs which include plausible values. Plausible values are random draws from a posterior density and are typically used to make comparisons on the group level (this is typical for large scale assessment data as PISA, PIAAC etc.).

}
\details{
\tabular{ll}{
Package: \tab svyPVpack\cr
Type: \tab Package\cr
Version: \tab 0.1\cr
Date: \tab 2013-04-03\cr
License: \tab GPL (>=2) \cr
}

}
\author{
Manuel Reif <Manuel.Reif@statistik.gv.at>

Jakob Peterbauer <Jakob.Peterbauer@statistik.gv.at>


Maintainer: Manuel Reif <Manuel.Reif@statistik.gv.at>

}
\references{

Saerndal, C.-E. & Swensson, B. & Wretman, J. (1992). \emph{Model Assisted Survey Sampling}. New York: Springer.


See also:

OECD (2013). \emph{Technical Report of the Survey of Adult Skills (PIAAC)}. Retrieved from: http://www.oecd.org/site/piaac/All\%20PIACC\%20Technical\%20Report\%20final.pdf

}

\keyword{ package }
\seealso{
\code{\link{svyPVglm}}
\code{\link{svyPVpm}}
}
\examples{


data(svy_example1)

erg_ben <- svyPVbenchmark(by = ~ sex, svydat=svy.exrep, pvs=c("plaus1","plaus2","plaus3"), BENCH=320)

erg_ben


}
