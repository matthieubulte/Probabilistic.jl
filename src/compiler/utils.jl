function >>(left::Expr, right::Expr)
    quote
        $left
        $right
    end
end

function mapcatexpr(f, xs)
    body = quote end
    for x in xs
        next = f(x)
        body = body >> next
    end
    prettify(body)
end

function brackets(i)
    var -> :($var[$i])
end

function condname(var)
    Symbol("cond__" * string(var))
end


function footer(observe)
    quote
        loglikelihood += current.loglikelihood
        if loglikelihood == -Inf
            $observe
            return traceroot
        end
        previous = current
        current = current.next
    end
end

function varbody(model, dist, var, access)
    invar = access(var)
    random = !haskey(model.conditionings, var)
    value = random ? :(rand($dist)) : access(condname(var))

    quote
        if current isa Leaf
            $invar = $value
            current = extend!(previous, $(quot(var)), $dist, $invar, $random)

            # TODO: we could move this if out of the runtime to avoid checking this
            # on each node
            if traceroot isa Leaf
                traceroot = current
            end
        else
            $invar = current.value
        end
    end
end
