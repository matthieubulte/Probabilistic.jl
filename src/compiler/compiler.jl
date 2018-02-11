function compile(model::Model)
    observe = mapcatexpr(s -> :(observations[$(quot(s))][observationid] = $s), model.observed)
    declareobserved = mapcatexpr(var -> :($var = nothing), model.observed)
    declareconds = mapcatexpr(cond -> :($(condname(cond.first)) = $(cond.second)), model.conditionings)

    body = postwalk(model.body) do x
        if @capture(x, var_[idx_] ~ dist_)
            varbody(model, dist, var, brackets(idx)) >> footer(observe)
        elseif @capture(x, var_ ~ dist_)
            varbody(model, dist, var, identity) >> footer(observe)
        elseif @capture(x, return ret_)
            observe >> :(return traceroot)
        else x
        end
    end

    r = quote
        function $(gensym())(traceroot::Trace, observations::Dict{Symbol,Array}, observationid::Int)
            $(model.params) = $(model.arguments)
            $declareconds
            $declareobserved

            loglikelihood = 1.0
            previous = traceroot
            current = traceroot

            $body
            $observe
            return traceroot
        end
    end
    return eval(r)
end
