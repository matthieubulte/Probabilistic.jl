# The multi distribution represents `n` independent draws of the
# distribution given as a parameter
struct Multi{T<:Distribution}
    n::Int
    distribution::T
end

function Distributions.logpdf(multi::Multi, samples)
    sum([logpdf(multi.distribution, sample) for sample in samples])
end

function Base.rand(multi::Multi)
    rand(multi.distribution, multi.n)
end
