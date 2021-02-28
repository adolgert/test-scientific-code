function trend_predict(x, m, kernel, transform, range)
    tail = x[(length(x) - m + 1):end]
    in_space = transform(tail)
    slope = kernel(in_space)
    predicted_space = slope * 1:range + space[end]
    inverse(transform(predicted_space))
end

x0 = [1.7, 1.9, 1.8, 1.4, 1.3, 1.4]
trend_trials = [
    [x0, 5, :weibull, :linear, 1, [2.3]],
    [x0, 5, :weibull, :log, 2, [2.4, 2.9]],
    [x0, 5, :exponential, :linear, 3, [2.1, 2.15, 2.18]],
    [x0, 5, :exponential, :log, 2, [2.31, 2.4, 2.47]],
]
for trial in trend_trials
    args = trial[1:5]
    result = trend_predict(args...)
    @test result == trial[6]
end
