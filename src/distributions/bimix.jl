# The BiMix distribution samples from a `leftdistribution` distribution with
# probability `p` and the `rightdistribution` with probability `1-p`. this
# is useful for efficiently defining mixture models upon two distributions,
# since it computes a marginalized pdf, thus saving the extra node in the
# execution trace for the mixture assignment.

struct BiMix{T<:Distribution,U<:Distribution}
    prob :: Float64
    leftdistribution :: T
    rightdistribution :: U
end

function Distributions.logpdf(bimix::BiMix, value)
    pleft = log(bimix.prob) + logpdf(bimix.leftdistribution, value)
    pright = log1p(-bimix.prob) + logpdf(bimix.rightdistribution, value)
    
    m = max(pleft, pright)
    m + log(exp(pleft - m) + exp(pright - m))
end

function Base.rand(bimix::BiMix)
    left = rand() <= bimix.prob
    rand(left ? bimix.leftdistribution : bimix.rightdistribution)
end
