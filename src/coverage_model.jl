using Turing
using Random
using StatsPlots

# Define a simple Normal model with unknown mean and variance.
@model function gdemo(x, y)
  s ~ InverseGamma(2, 3)
  m ~ Normal(0, sqrt(s))
  x ~ Normal(m, sqrt(s))
  y ~ Normal(m, sqrt(s))
end

#  Run sampler, collect results
chn = sample(gdemo(1.5, 2), HMC(0.1, 5), 1000)

# Summarise results
describe(chn)

# Plot and save results
p = plot(chn)
savefig("gdemo-plot.png")

p_true = 0.5

# Iterate from having seen 0 observations to 100 observations.
Ns = 0:100

# Draw data from a Bernoulli distribution, i.e. draw heads or tails.
Random.seed!(12)
data = rand(Bernoulli(p_true), last(Ns))
@model function coinflip(y)
    # Our prior belief about the probability of heads in a coin.
    p ~ Beta(1, 1)

    # The number of observations.
    N = length(y)
    for n in 1:N
        # Heads or tails of a coin are drawn from a Bernoulli distribution.
        y[n] ~ Bernoulli(p)
    end
end

# Settings of the Hamiltonian Monte Carlo (HMC) sampler.
iterations = 1000
ϵ = 0.05
τ = 10

# Start sampling.
chain = sample(coinflip(data), HMC(ϵ, τ), iterations)

# Plot a summary of the sampling process for the parameter p, i.e. the probability of heads in a coin.
histogram(chain[:p])

K = 5
@model function one_parameter(y)
    N = length(y)
    a ~ Beta(2,5)
    b ~ Beta(2,5)
    c ~ Beta(2,5)
    d ~ Beta(2,5)
    e ~ Beta(2,5)
    pvec = [a, b, c, d, e]
    for i in 1:N
        y[i] ~ Categorical(pvec / sum(pvec))
    end
end

data = rand(Categorical([0.1, 0.1, 0.1, 0.2, 0.5]), 100)
chain = sample(one_parameter(data), PG(10), 1000)
chain = sample(one_parameter(data), HMC(0.1, 5), 1000)
chain = sample(one_parameter(data), NUTS(0.65), 1000)


# This model, using arrays of values, isn't working at all.
# It yields the same number for a, b, c, d, and e. .285
@model function one_parameter(y)
    N = size(y, 2)
    a ~ Beta(2,5)
    b ~ Beta(2,5)
    c ~ Beta(2,5)
    d ~ Beta(2,5)
    e ~ Beta(2,5)
    avec = [a, b]
    bvec = [c, d, e]
    aval ~ Categorical(avec / sum(avec))
    bval ~ Categorical(bvec / sum(bvec))
    for i in 1:N
        y[1, i] = aval
        if aval == 1
            y[2, i] = 1
        else
            y[2, i] = bval
        end
    end
end

N = 10000
data = zeros(Int, 2, N)
data[1, :] = rand(Categorical([0.2, 0.8]), N)
data[2, :] = rand(Categorical([0.4, 0.2, 0.4]), N)
for i in 1:N
    if data[1, i] == 1
        data[2, i] = 1
    end
end
chain = sample(one_parameter(data), PG(10), 10000)

using Interpolations
A_x1 = 1:.1:10
A_x2 = 1:.5:20
f(x1, x2) = log(x1+x2)
# row is x1, col is x[2]
A = [f(x1,x2) for x1 in A_x1, x2 in A_x2]
itp = interpolate(A, BSpline(Cubic(Line(OnGrid()))))
sitp = scale(itp, A_x1, A_x2)
sitp(5., 10.) # exactly log(5 + 10)
sitp(5.6, 7.1) # approximately log(5.6 + 7.1)
using CSV

function infer_range(float_list)
    start = minimum(float_list)
    finish = maximum(float_list)
    count = length(float_list)
    delta = (finish - start) / (count - 1)
    start:delta:finish
end

infer_range(collect(0.1:.1:3))

for check in [0.01:.01:2.99, 1:1:5]
    @assert infer_range(collect(check)) == check
end


function interpolate_mesh()
    mesh_fn = "/home/adolgert/dev/analytics-pipeline/pr2ar_mesh.csv"
    row_cnt = 0
    for row in CSV.File(mesh_fn)
        row_cnt += 1
    end
    pr = zeros(Float64, row_cnt)
    rho = zeros(Float64, row_cnt)
    ar = zeros(Float64, row_cnt)
    row_idx = 1
    for row in CSV.File(mesh_fn)
        pr[row_idx] = row.PR
        rho[row_idx] = row.rho
        ar[row_idx] = row.AR
        row_idx += 1
    end
    rho_axis = sort(unique(rho))
    rho_scale = infer_range(rho_axis)
    pr_axis = sort(unique(pr))
    pr_scale = infer_range(pr_axis)
    rho_cnt = length(rho_axis)
    pr_cnt = length(pr_axis)
    @assert length(collect(pr_scale)) == pr_cnt
    @assert length(collect(rho_scale)) == rho_cnt
    rho_stride = findall(x -> x == rho_axis[1], rho)
    if rho_stride[1:10] == 1:10
        ar = reshape(ar, (rho_cnt, pr_cnt))
        println("rho rows, pr cols")
        itp = interpolate(ar, BSpline(Cubic(Line(OnGrid()))))
        sitp = Interpolations.scale(itp, rho_scale, pr_scale)
    else
        ar = reshape(ar, (pr_cnt, rho_cnt))
        itp = interpolate(ar, BSpline(Cubic(Line(OnGrid()))))
        println("pr rows, rho cols")
        sitp = Interpolations.scale(itp, pr_scale, rho_scale)
    end
    sitp
end

prfunc = interpolate_mesh()

function foi_from_pram(pfpr, am, k = 0.6, tau = 10)
    rho = k * am
    alpha = prfunc(pfpr, rho)
    h = -log(1 - alpha) / tau
    h
end
foi_from_pram(0.4, 0.3)

@model function foi_model(x)
    k ~ Beta(2, 5)
    rho = k * x[1]
    alpha = prfunc(x[2], rho)
    x[3] = -log(1 - alpha) / 10
end
chn = sample(foi_model([0.3, 0.2, 0.01]), PG(10), 1000)

