struct Metropolis
    steps::Int
    perturb

    Metropolis(steps::Int, perturb) = new(steps, perturb)
    Metropolis(steps::Int) = new(steps, genericperturb)
end

function genericperturb(node::Node)
    throw("Not implemented: genericperturb")
end

function run(config::Metropolis, model::Model)
    runmodel = compile(model)

    observations = Dict{Symbol, Array}()
    foreach(var -> observation[var] = Array{Any}(config.steps), model.observed)

    trace = runmodel(nothing, observations, 1)
    lhood = loglikelihood(trace)

    for i = 2:config.steps
        proposal = propose(trace, config.perturb)
        proposal = runmodel(proposal, observations, i)
        newlhood = loglikelihood(proposal)

        if rand() <= exp(newlhood - lhood)
            trace = proposal
            lhood = newlhood
        else
            # overwrite the observations since proposal was rejected
            foreach(var -> observation[var][i] = observation[var][i-1], model.observed)
        end
    end

    observations
end
