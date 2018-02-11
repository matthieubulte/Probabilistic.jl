module Probabilistic

using Base.Meta: quot
import Base: copy
using Distributions
using MacroTools
using MacroTools: postwalk, prettify


include("model.jl")

include("compiler/utils.jl")
include("compiler/compiler.jl")

include("distributions/bimix.jl")
include("distributions/multi.jl")

include("sampling/trace.jl")
include("sampling/metropolis.jl")
include("sampling/sample.jl")

export @model, Model, condition, observe, sample, Metropolis, BiMix, Multi

end
