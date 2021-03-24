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
function langevin(x::T) where {T}
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


function langevin_mean_age(mx::Vector{T}, nx) where {T}
    (nx / T(2)) .* (one(T) .- langevin.(mx .* nx / T(2)))
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
