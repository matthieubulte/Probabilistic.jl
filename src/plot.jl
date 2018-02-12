
function plotresult(result::Tuple{Dict{Symbol, Array},Array})
    observations, loglikelihoods = result

    nsamples = length(loglikelihoods)
    nvars = length(observations)
    i = 0
    for (var,samples) in observations
        subplot(nvars+1,2,2*i+1); plt[:hist](samples, color="black")
        subplot(nvars+1,2,2*i+2); scatter(1:nsamples, samples, s=1, c="black", alpha=0.1)
        i += 1
    end
    subplot(nvars+1,1,nvars+1)
    plot(1:nsamples, loglikelihoods, linewidth=1, c="black")
end
