
Leaf = Void
mutable struct Node{D<:Distribution}
    name::Symbol
    distribution::D
    value::Any
    loglikelihood::Float64
    israndom::Bool
    next::Union{Node,Leaf}
end
Trace = Union{Leaf, Node}


function extend!{D<:Distribution}(previous::Trace, name::Symbol, distribution::D, value, israndom::Bool)
    node = Node(name, distribution, value, logpdf(distribution, value), israndom, nothing)
    if !(previous isa Leaf)
        previous.next = node
    end
    node
end

function len(node::Trace)
    node isa Leaf ? 0 : 1+len(node.next)
end

function toarray(trace::Trace)
    length = len(trace)
    arr = Array{Node}(length); arr[1] = trace
    foreach(i -> arr[i] = arr[i-1].next, 2:length)
    arr
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
    proposal = deepcopy(trace) # TODO: implement copy in trace to avoid extra copying
                               # NOTE: traces could be implemented as tries

    nodes = shuffle(toarray(proposal))

    perturb_idx = findfirst(n -> n.israndom, nodes)
    node = nodes[perturb_idx]

    node.value = perturb(node)
    node.loglikelihood = logpdf(node.distribution, node.value)
    node.next = nothing

    return proposal
end
