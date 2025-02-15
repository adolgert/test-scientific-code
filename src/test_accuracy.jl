"""
Given a function, what are some automated tests of the numerical accuracy
of that function? This file looks at applying a set of methods to an example.
"""
using IntervalArithmetic
using StaticArrays

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

using StaticArrays
const bigvals = SVector(
    BigFloat("3"), BigFloat("15"), BigFloat("35"), BigFloat("63"), BigFloat("99"))

function typish(x::T) where {T}
    three = parse(T, "3")
    three * x
end


function lackish(x::T) where {T}
    three = T(3)
    three * x
end

function prish(x::BigFloat)
    bigvals[1] * x
end


# Will there be trouble with calculating life expectancy? Maybe
# from multiplying conditional survival so many times?
const _ql = SVector(
    BigFloat("1"), BigFloat("2"), BigFloat("115"), BigFloat("0")
)

S(x) = max((115 - x) / 115, 0)
S(x::BigFloat) = max((_ql[3] - x) / _ql[3], _ql[4])
S(x, y) = S(y) / S(x)

function survival(x, n)
    p = one(x)
    stops = LinRange(zero(x), x, n + 1)
    for i in 1:n
        p *= S(stops[i], stops[i + 1])
    end
    p
end

s64 = survival(114, 100 * 52)
sbig = survival(BigFloat("114"), 100 * 52)
@assert -log2((s64 - sbig) / sbig) > 56
@assert -log2((s64 - sbig) / sbig) < 57
