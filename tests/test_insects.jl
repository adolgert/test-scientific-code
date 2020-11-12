rel_error(a, b) = (a - b) / b
abs_rel_error(a, b) = abs((a - b) / b)

function trimmed_mean(x)
    l, u = quantile(x, [0.2, 0.8])
    mean(x[(x .> l) .& (x .< u)])
end


rng = MersenneTwister(9237429)
parameters = Dict(
    :max_food => 400,
    :food_alpha => 2,
    :food_beta => 10,
    :growth_rate => 1.5,
    :death_rate => 1.05
)

######### testing beverton_holt(x, K, nu, mu)

# If available food is constant, and the population begins under the
# maximum, then it will approach the maximum in the limit but not exceed it.
step_cnt = 200
constant_food = beverton_holt_constant_food(2, step_cnt, parameters)
@test all(constant_food .< 400)
@test abs_rel_error(constant_food[step_cnt], parameters[:max_food]) < 1e-10

# Assert the value is decreasing.
greater_cnt = 0
for diff_idx in 1:(step_cnt - 1)
    if constant_food[diff_idx + 1] < diff_idx
        greater_cnt += 1
    end
end
@test greater_cnt == 0

# If the population begins high, and food is constant, it will fall.
high_pop = 2 * parameters[:max_food]
high_food = beverton_holt_constant_food(high_pop, step_cnt, parameters)
@test all(high_food .> 400)
# Falling slowly because rate is 1.05, so this value is 0.015.
@test abs_rel_error(high_food[step_cnt], parameters[:max_food]) < 0.015

# If the nu and mu are in the right order in the function, then the rise to
# max population will be faster than the fall from high population.
@test abs(constant_food[step_cnt] - 400) < abs(high_food[step_cnt] - 400)


########## testing forecast_population(young, step_cnt, params, rng)

# Increasing the food parameter increases the average value.
lower_food_parameters = copy(parameters)
lower_food_parameters[:max_food] = parameters[:max_food] / 2
high_food = forecast_population(50, 10000, parameters, rng)
low_food = forecast_population(50, 10000, lower_food_parameters, rng)
@test mean(high_food) > mean(low_food)

# Increasing the death rate should lower the average.
# Decreasing the death rate should raise it.
death_rate_trials = collect(0.5:0.1:1.5)
for death_rate in death_rate_trials
    higher_death_parameters = copy(parameters)
    higher_death_parameters[:death_rate] = 1 + (parameters[:death_rate] - 1) * death_rate
    # Copy the rng to get the same draws of random numbers.
    # It's a "variance reduction technique".
    rng2 = copy(rng)
    low_death = forecast_population(50, 10000, parameters, rng)
    high_death = forecast_population(50, 10000, higher_death_parameters, rng2)
    if death_rate < 0.99
        @test trimmed_mean(high_death) > trimmed_mean(low_death)
    elseif death_rate > 1.01
        @test trimmed_mean(high_death) < trimmed_mean(low_death)
    else
        @test abs(trimmed_mean(high_death) - trimmed_mean(low_death)) < 1
    end
end

# The means are near the same value where I last saw them.
long_run_cnt = 100
long_run_max = 10000
long_run_means = zeros(long_run_cnt)
long_run_trimmed = zeros(long_run_cnt)
for long_run_idx in 1:long_run_cnt
    long_run = forecast_population(2, long_run_max, parameters, rng)
    long_run_later = long_run[1000:long_run_max]
    long_run_means[long_run_idx] = mean(long_run)
    long_run_trimmed[long_run_idx] = trimmed_mean(long_run)
end

for lr_arr in [long_run_means, long_run_trimmed]
    @test abs(mean(lr_arr) - 72.5) < 0.5
    @test std(lr_arr) < 0.6
end


# Build an empirical distribution function.
single_sample = forecast_population(50, long_run_max, parameters, rng)
default_cdf = StatsBase.ecdf(single_sample[1000:long_run_max])
