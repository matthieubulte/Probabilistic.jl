+ generic perturb

+ make high order distributions real distributions

+ smc

+ remove header abstraction
    progress here, at least compile is a bit cleaner. Still have to find a way to:
        1. inject code in the given body # DONE
        2. find a clean way to interact between the sampler and the model

API should be smt like:

brownian = @model N begin
    σ ~ Beta(2, 3)
    x = zeros(N)
    for i = 2:N
       x[i] ~ Normal(x[i-1], σ^2)
    end
end

N = 20
X = cumsum((0.75^2)*randn(N))

result = sample(brownian(N)
                    |> condition(:x => X)
	                |> observe(:σ),
	            metropolis(5000))


# ============================================
mix = @model N begin
    prob ~ Beta(2, 2)

    mean0 ~ Normal(-1,1)
    mean1 ~ Normal(1,1)

    x = zeros(N)
    for i = 1:N
        x[i] ~ BiMix(prob, Normal(mean0, 0.2), Normal(mean1, 0.2))
    end
end

obs = [-1.7, -1.8, -2.01, -2.4, 1.9, 1.8]
N = length(obs)

header = sample(mix(N),
		condition(:x => obs),
		observe(:prob, :mean0, :mean1),
		metropolis(50_000))
