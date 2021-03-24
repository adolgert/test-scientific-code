"""
Given a function, what are some automated tests of the numerical accuracy
of that function? This file looks at applying a set of methods to an example.
"""


# 1) Compare with a version using greater precision.
mxs = ["1", "3", "100", "0.1", "0.01", "0.001", "0.0001", "0.00001", "0.000001"]
order = zeros(BigFloat, length(mxs))
for (mxidx, mx) in enumerate(mxs)
    big = BigFloat(mx)
    nx = BigFloat("1")
    mxb = constant_mortality_mean_age([big], [nx])

    mxf = constant_mortality_mean_age([parse(Float64, mx)], [1.0])
    order[mxidx] = log10(abs((BigFloat(mxf[1]) - mxb[1]) / mxb[1]))
end
order


# 2) Run with a round down and a round up.
initial_rounding = rounding(BigFloat)
bfprecision = 32
mxs = ["1", "3", "100", "0.1", "0.01", "0.001", "0.0001", "0.00001", "0.000001"]
round_modes = [RoundDown, RoundUp, RoundFromZero, RoundToZero]
rounded = zeros(BigFloat, length(round_modes), length(mxs))
for (mxidx, mx) in enumerate(mxs)
    for (ridx, round_mode) in enumerate(round_modes)
        setrounding(BigFloat, round_mode)

        big = BigFloat(mx; precision = bfprecision)
        nx = BigFloat("1"; precision = bfprecision)
        mxb = constant_mortality_mean_age([big], [nx])
        rounded[ridx, mxidx] = mxb[1]
    end
end
setrounding(BigFloat, initial_rounding)

absdiff = vec(maximum(rounded; dims = 1) -  minimum(rounded; dims = 1))


# 3) Run with interval arithmetic.
using IntervalArithmetic
mxs = ["1", "3", "100", "0.1", "0.01", "0.001", "0.0001", "0.00001", "0.000001"]
iaorder = zeros(Interval{Float64}, length(mxs))
for (mxidx, mx) in enumerate(mxs)
    mxf = parse(Float64, mx)
    mxi = @interval(mxf, mxf)
    nx = @interval(1.0, 1.0)
    axf = constant_mortality_mean_age([mxi], [nx])
    iaorder[mxidx] = axf[1]
end
iaorder


# 4) Run an optimizer to search for maximum error.
using Optim

function cm_error(mx)
    nx = BigFloat("1")
    mxb = constant_mortality_mean_age([mx], [nx])

    mxf = constant_mortality_mean_age([Float64(mx)], [1.0])
    -abs((BigFloat(mxf[1]) - mxb[1]) / mxb[1])
end

# This will use Brent's method, so it stops when the output isn't smooth.
maxerr = optimize(cm_error, BigFloat("0"), BigFloat("10"))
"""
julia> maxerr = optimize(cm_error, BigFloat("0"), BigFloat("10"))
Results of Optimization Algorithm
 * Algorithm: Brent's Method
 * Search Interval: [0.000000, 10.000000]
 * Minimizer: 5.209083e+00
 * Minimum: -1.963027e-16
 * Iterations: 184
 * Convergence: max(|x - x_upper|, |x - x_lower|) <= 2*(4.2e-39*|x|+1.7e-77): true
 * Objective Function Calls: 185
 """

 """
 julia> maxerr = optimize(cm_error, BigFloat("0"), BigFloat("2"))
Results of Optimization Algorithm
 * Algorithm: Brent's Method
 * Search Interval: [0.000000, 2.000000]
 * Minimizer: 9.979240e-01
 * Minimum: -4.815448e-16
 * Iterations: 184
 * Convergence: max(|x - x_upper|, |x - x_lower|) <= 2*(4.2e-39*|x|+1.7e-77): true
 * Objective Function Calls: 185
 """


using Evolutionary

function cm_error_arr(mxarr)
   mx = mxarr[1]
   nx = BigFloat("1")
   mxb = constant_mortality_mean_age([mx], [nx])

   mxf = constant_mortality_mean_age([Float64(mx)], [1.0])
   -abs((BigFloat(mxf[1]) - mxb[1]) / mxb[1])
end

ga = GA(populationSize=100,selection=uniformranking(3),
    mutation=gaussian(),crossover=uniformbin())
lower = [eps(Float64)]
lower = [1e-10]
upper = [2.0]
x0 = [1.0]
results = Evolutionary.optimize(cm_error_arr, lower, upper, x0, ga)
"""
julia>  results = Evolutionary.optimize(cm_error_arr, lower, upper, x0, ga)

 * Status: failure (reached maximum number of iterations)

 * Candidate solution
    Minimizer:  [0.0]
    Minimum:    NaN
    Iterations: 1000

 * Found with
    Algorithm: GA[P=100,x=0.8,μ=0.1,ɛ=0]

 * Work counters
    Seconds run:   0.7939 (vs limit Inf)
    Iterations:    1000
    f(x) calls:    100120
"""

"""
julia> results = Evolutionary.optimize(cm_error_arr, lower, upper, x0, ga)

 * Status: success

 * Candidate solution
    Minimizer:  [2.220446049250313e-16]
    Minimum:    -1.0
    Iterations: 12

 * Found with
    Algorithm: GA[P=100,x=0.8,μ=0.1,ɛ=0]

 * Work counters
    Seconds run:   0.0065 (vs limit Inf)
    Iterations:    12
    f(x) calls:    1301
"""