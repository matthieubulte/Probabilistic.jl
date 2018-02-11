
function plotresult(result::Dict{Symbol, Array})
    nvars = length(result)
    i = 0
    for (var,samples) in result
        title(string(var))
        subplot(nvars,2,2*i+1); plt[:hist](samples)
        subplot(nvars,2,2*i+2); scatter(1:length(samples), samples, s=1)
        i += 1
    end
end
