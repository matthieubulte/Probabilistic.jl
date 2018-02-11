mutable struct Model
    body::Expr
    params::Expr
    arguments::Tuple
    conditionings::Dict{Symbol,Any}
    observed::Set{Symbol}

    Model(body::Expr) = new(body, :(), (), Dict(), Set())
    Model(body::Expr, params::Expr) = new(body, params, (), Dict(), Set())
    Model(body::Expr, params::Expr, arguments::Tuple, conditionings::Dict{Symbol,Any}, observed::Set{Symbol}) = new(body, params, arguments, conditionings, observed)
end

macro model(body::Expr)
    Model(prettify(body))
end

macro model(param::Symbol, body::Expr)
    Model(prettify(body), :(($param,)))
end

macro model(params::Expr, body::Expr)
    Model(prettify(body), params)
end

function copy(model::Model)
    Model(model.body, model.params, model.arguments, Dict(model.conditionings), Set(model.observed))
end

function condition{T}(conds::Vararg{Pair{Symbol,T}})
    (model::Model) -> let
        newmodel = copy(model)
        for cond in conds
            newmodel.conditionings[cond.first] = cond.second
        end
        newmodel
    end
end

function observe(obs::Vararg{Symbol})
    (model::Model) -> let
        newmodel = copy(model)
        union!(newmodel.observed, Set(obs))
        newmodel
    end
end

function (model::Model)(args :: Vararg)
    newmodel = copy(model)
    newmodel.arguments = args
    newmodel
end
