function constant_mortality_mean_age(mx, nx, boundary = 1e-6)
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

function constant_mortality_mean_age_uncorrected(mx, nx)
    expx = exp.(-mx .* nx)
    (1 ./ mx) .- (nx .* expx) ./ (1 .- expx)
end
