require(MASS)

qn <- function() q(save='no')
qy <- function() q(save='yes')
ex <- example
ed <- edit
type <- function(x=.Last.value) c(class(x),mode(x),typeof(x))
len  <- function(x=.Last.value) length(x)
laapply <- function(...,x=.Last.value) sapply(...,function(f) f(x)) # call N funcs
# TODO fix laapply, possibly use environment.
