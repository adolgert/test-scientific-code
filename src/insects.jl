using Random

function logistic_population(r, K, p0, t)
  K / (1 + ((K - p0) / p0) * exp(-r * t))
end


function logistic_difeq(x)
    P, r, K = x
    r * P * (1 - P / K)
end


function pop(young, params, rng)
    food = params[:maxfood] * rand(rng, Beta(params[:food_alpha], params[:food_beta]))
end


function run_pop()
    rng = MersenneTwister(9237429)
    parameters = Dict(
        :maxfood => 20,
        :food_alpha => 2,
        :food_beta => 5,
        :growth_rate => 2.1,
    )
    pop(21, parameters, rng)
end