struct Metropolis
    steps::Int
    perturb

    Metropolis(steps::Int, perturb) = new(steps, perturb)
    Metropolis(steps::Int) = new(steps, genericperturb)
end

# TODO: this is bad
function genericperturb(node::Node)
    if node.distribution isa Normal
        node.value + std(node.distribution) * randn()
    elseif node.distribution isa Beta
        node.value + .1 * randn()
    elseif node.distribution isa BiMix
        node.value + randn()
    else
        rand(node.distribution)
    end
end

function run(config::Metropolis, model::Model)
    runmodel = compile(model)

    observations = Dict{Symbol, Array}()
    loglikelihoods = Array{Float64}(config.steps)
    foreach(var -> observations[var] = Array{Any}(config.steps), model.observed)

    trace = Base.invokelatest(runmodel, nothing, observations, 1)
    lhood = loglikelihood(trace)
    loglikelihoods[1] = lhood

    for i = 2:config.steps
        proposal = propose(trace, config.perturb)
        proposal = Base.invokelatest(runmodel, proposal, observations, i)
        newlhood = loglikelihood(proposal)

        # NOTE: this is assuming that the proposal kernel for each var is symmetrical, bad
        if log(rand()) <= newlhood - lhood
            trace = proposal
            lhood = newlhood
        else
            # overwrite the observations since proposal was rejected
            foreach(var -> observations[var][i] = observations[var][i-1], model.observed)
        end
        loglikelihoods[i] = lhood
    end

    observations, loglikelihoods
end
