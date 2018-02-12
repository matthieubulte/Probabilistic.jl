
Leaf = Void
mutable struct Node
    name::Symbol
    distribution # TODO find a way to type this
    value::Any
    loglikelihood::Float64
    israndom::Bool
    next::Union{Node,Leaf}
end
Trace = Union{Leaf, Node}

function copyupto(trace::Trace, upto::Node)
    if trace isa Leaf
        trace,trace
    elseif trace == upto
        newupto = Node(upto.name, upto.distribution, upto.value, upto.loglikelihood, upto.israndom, nothing)
        newupto,newupto
    else
        head = Node(trace.name, trace.distribution, trace.value, trace.loglikelihood, trace.israndom, nothing)
        rest,upto = copyupto(trace.next,upto)
        head.next = rest
        head,upto
    end
end

function extend!(previous::Trace, name::Symbol, distribution, value, israndom::Bool)
    node = Node(name, distribution, value, logpdf(distribution, value), israndom, nothing)
    if !(previous isa Leaf)
        previous.next = node
    end
    node
end

function getrandnode(n::Int, node::Trace)
    (n<=1 || node isa Leaf) ? node : getrandnode(n-(node.israndom ? 1 : 0), node.next)
end

function countrandom(node::Trace)
    node isa Leaf ? 0 : (node.israndom ? 1 : 0) + countrandom(node.next)
end

function Distributions.loglikelihood(trace::Trace)
    loglikelihood = 1.0
    current = trace
    while !(current isa Leaf)
        loglikelihood += current.loglikelihood
        current = current.next
    end
    loglikelihood
end

function propose(trace::Trace, perturb)
    nrandoms = countrandom(trace)
    nodeid = rand(1:nrandoms)
    node = getrandnode(nodeid, trace)

    proposal,node = copyupto(trace,node)

    node.value = perturb(node)
    node.loglikelihood = logpdf(node.distribution, node.value)
    node.next = nothing

    return proposal
end
