using StaticArrays


function constant_mortality_mean_age_corrected(mx, nx, boundary = 1e-6)
    result = copy(mx)
    upper = mx .>= boundary
    large_mx  = mx[upper]
    expx = exp.(-large_mx .* nx[upper])
    result[upper] = (1 ./ large_mx) .- (nx[upper] .* expx) ./ (1 .- expx)

    lower = .!upper
    small_mx = mx[lower]
    small_nx = nx[lower]
    result[lower] = small_nx .* (0.5 .+ small_nx .* (
        -small_mx / 12 + small_mx.^3 .* small_nx.^2 / 720))
    result
end


function constant_mortality_mean_age(mx::Vector{T}, nx) where {T}
    expx = exp.(-mx .* nx)
    (one(T) ./ mx) .- (nx .* expx) ./ (one(T) .- expx)
end

# The Langevin function is coth(x) - 1/x
function langevin_low(x::T) where {T}
    x / T(3) / (
        one(T) + x^2 / T(15) / (
            one(T) + x^2 / T(35) / (
                one(T) + x^2 / T(63) / (
                    one(T) + x^2 / T(99)
                )
            )
        )
    )
end

let _bl = SVector(
    BigFloat("1"), BigFloat("3"), BigFloat("15"), BigFloat("35"), BigFloat("63"), BigFloat("99"))
    global langevin_high
    # The Langevin function is coth(x) - 1/x
    function langevin_high(x::T) where {T}
        coth(x) - one(T) / x
    end
end

let _bl = SVector(BigFloat("1"))
    global langevin_high
    function langevin_high(x::T) where {T <: BigFloat}
        coth(x) - _bl[1] / x
    end
end


function langevin_low(x::T) where {T <: BigFloat}
    x / _bl[2] / (
        _bl[1] + x^2 / _bl[3] / (
            _bl[1] + x^2 / _bl[4] / (
                _bl[1] + x^2 / _bl[5] / (
                    _bl[1] + x^2 / _bl[6]
                )
            )
        )
    )
end


function langevin_crossover(x, crossover = 0.29)
    x < crossover && return langevin_low(x)
    langevin_high(x)
end


function langevin(x, (low, high))
    if x < low
        langevin_low(x)
    elseif x < high
        ((x - low) * langevin_low(x) + (high - x) * langevin_high) / (high - low)
    else
        langevin_high(x)
    end
end


# Using https://herbie.uwplse.org/doc/latest/tutorial.html
function langevin_herbie(x)
    (x * 0.3333333333333333 + (cbrt(x) * cbrt(x))^5 * 0.0021164021164021165 * cbrt(x)^5) -
            x^3 * 0.022222222222222223
end


function langevin_herbie2(x)
    return (x * 0.3333333333333333 + log(exp(0.0021164021164021165 * x^5))) - x^3 * 0.022222222222222223
end


# (1 / 3) * z - (1 / 45) * z^3 + (2 / 945) * z^5
function langevin_laurent(z)
    Base.Math.evalpoly(z, (0.0, 1.0 / 3.0, 0.0, -1.0 / 45.0, 0.0, 2.0 / 945.0))
end


function langevin_mean_age(mx::Vector{T}, nx) where {T}
    (nx / T(2)) .* (one(T) .- langevin.(mx .* nx / T(2)))
end


"""
Approximation for low mx from algebra.py.
"""
function mean_age_low(mx, nx)
    x = mx * nx * 0.5
    r = evalpoly(x, (2027025, - 675675, 270270, - 45045, 6930, -594, 36, 1)) /
            evalpoly(x^2, (9 * 225225, 9 * 30030, 9 * 770, 9 * 4))
    0.5 * nx * r
end


function test_naive_mean_age()
    mx = vcat([0.9 * 10.0^i for i in 0:-1:-17], [0.0])
    nx = ones(size(mx))
    ax = constant_mortality_mean_age(mx, nx)
    println(ax)
    for check in 2:length(ax)
        @assert ax[check] > ax[check - 1]
    end
    @assert all(ax .< .5)
end
