using Distributions
using Random


function logistic_population(r, K, p0, t)
  K / (1 + ((K - p0) / p0) * exp(-r * t))
end


function logistic_difeq(x)
    P, r, K = x
    r * P * (1 - P / K)
end


@doc raw"""
    beverton_holt(x, K, nu, mu)

Given a population of size x, generate a population at the next time step.
`K` is the limiting population. `nu` is the growth rate. The Beverton-Holt
model normally has just `nu` as a growth rate. This one adds `mu` as
a rate at which the system decreases to the limiting population.
"The Beverton-Holt dynamic equation" by Bohner and Warth, 2007
"""
function beverton_holt(x, K, nu, mu)
    @assert nu > 1
    @assert mu > 1
    if x <= K
        rate = nu
    else
        rate = mu
    end
    (rate * K * x) / (K + (rate - 1) * x)
end


@doc raw"""
    beverton_holt_constant_food(young, step_cnt, params)

Predict `step_cnt` time steps of a future population, starting with `young`
individuals and using parameters in the `params` dictionary. In this version,
it reads the amoung of food from the parameter called `:max_food`.
"""
function beverton_holt_constant_food(young, step_cnt, params)
    x = zeros(Float64, step_cnt)
    x[1] = young
    for step_idx = 1:(step_cnt - 1)
        x[step_idx + 1] = beverton_holt(
            x[step_idx], params[:max_food], params[:growth_rate], params[:death_rate]
            )
    end
    x
end


@doc raw"""
    forecast_population(young, step_cnt, params, rng)

Predict `step_cnt` time steps of a future population, starting with `young`
individuals and using parameters in the `params` dictionary. `rng` is
a random number generator.
"""
function forecast_population(young, step_cnt, params, rng)
    food = zeros(Float64, step_cnt)
    rand!(rng, Distributions.Beta(params[:food_alpha], params[:food_beta]), food)
    food .*= params[:max_food]

    x = zeros(Float64, step_cnt)
    x[1] = young
    for step_idx = 1:(step_cnt - 1)
        x[step_idx + 1] = beverton_holt(x[step_idx], food[step_idx], params[:growth_rate], params[:death_rate])
    end
    x
end


function run_pop()
    rng = MersenneTwister(9237429)
    parameters = Dict(
        :max_food => 400,
        :food_alpha => 2,
        :food_beta => 10,
        :growth_rate => 1.5,
        :death_rate => 1.05
    )
    forecast_population(2, 200, parameters, rng)
end
