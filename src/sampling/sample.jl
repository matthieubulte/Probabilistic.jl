
# that's still a very lame function, but might be useful once more sampling
# algorithms are implemented (or not...)
function sample(model::Model, algorithm)
    run(algorithm, model)
end
