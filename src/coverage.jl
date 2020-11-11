using Combinatorics: combinations
using Random

a = Set{NTuple{3,Int8}}()
push!(a, (3, 7, 4))
push!(a, (4, 2, 9))
(3, 7, 4) in a
b = (2, 4, 6)
length(b)
NTuple{3,Int8}([1,2,3])
ad = Dict{NTuple{3,Int8},Set{NTuple{3,Int8}}}()
ad[(1, 2, 3)] = Set{NTuple{3,Int8}}()
push!(ad[(1, 2, 3)], (1, 4, 7))
ad = Dict{NTuple{n_way,Int8},Set{NTuple{n_way,Int8}}}()

bs = BitSet([1,2,5])
bs
param_keys = [x for x in collect(Combinatorics.combinations(1:param_cnt, n_way))]
binary_key = zeros(Int8, param_cnt)
binary_key[key] .= 1

# Define the problem.
n_way = 3
param_cnt = 5
param_size = Int[2,2,3,2,3]

param_keys = [NTuple{n_way,Int8}(x) for x in collect(Combinatorics.combinations(1:param_cnt, n_way))]

combinations = zeros(Int, length(param_size))
for comb_idx in 1:param_cnt
    total = sum([prod(key_set) for key_set in param_keys if comb_idx in key_set])
    for key_set in param_keys
        total += prod(key_set)
    end
    combinations[comb_idx] = total
end
combinations
ad = Dict{NTuple{n_way,Int8},Set{NTuple{n_way,Int8}}}()
# The N here is the n-way. Doesn't care yet how many parameters.
struct CT{T where T <: Tuple{Vararg{T,N}}}
    ad::Dict{NTuple{N,T},Set{NTuple{N,T}}}
    N::Int
    CT(N) = new(Dict{NTuple{N,T},Set{NTuple{N,T}}}(), N)
end

using Combinatorics: combinations
# The N here is the n-way. Doesn't care yet how many parameters.

struct CombinationTracker
    ad
    N::Int
    CombinationTracker(N) = new(Dict{NTuple{N,Int8},Set{NTuple{N,Int8}}}(), N)
end


function tracker(n_way, param_cnt)
    @assert param_cnt >= n_way
    param_keys = [NTuple{n_way,Int8}(x) for x in collect(combinations(1:param_cnt, n_way))]
    track = CombinationTracker(n_way)
    for key in param_keys
        track.ad[key] = Set{NTuple{n_way,Int8}}()
    end
    track
end


function initialize_tracker(tracker, seed)
    n_way = tracker.N
    param_cnt = size(seed, 2)
    for incoming_idx in 1:size(seed, 1)
        bit_nonzero = seed[incoming_idx, :] .!= 0
        which_nonzero = (1:param_cnt)[bit_nonzero]
        idx = NTuple{n_way,Int8}(which_nonzero)
        values = NTuple{n_way,Int8}(seed[incoming_idx, bit_nonzero])
        push!(tracker.ad[idx], values)
    end
end

# These are combinations per possible value of each parameter.
# For instance, [2,3,4]. it would be [7, 6, 5] for 2-way.
function combinations_per_value(arity, n_way)
    param_cnt = length(arity)
    per_value = zeros(Int, param_cnt)
    # param_keys = [NTuple{n_way,Int8}(x) for x in collect(Combinatorics.combinations(1:param_cnt, n_way))]
    param_keys = [x for x in collect(combinations(1:param_cnt, n_way))]
    for comb_idx in 1:param_cnt
        factor = arity[comb_idx]
        total = sum([prod(arity[key_set]) / factor for key_set in param_keys if comb_idx in key_set])
        per_value[comb_idx] = total
    end
    per_value
end

function total_combinations(arity, n_way)
    param_cnt = length(arity)
    sum(prod(arity[key_set]) for key_set in combinations(1:param_cnt, n_way))
end

incoming_idx = 1
bit_nonzero = seed[incoming_idx, :] .!= 0
which_nonzero = (1:param_cnt)[bit_nonzero]
idx = NTuple{n_way,Int8}(which_nonzero)
values = NTuple{n_way,Int8}(seed[incoming_idx, bit_nonzero])
push!(ad[idx], values)


for incoming_idx in 1:size(seed, 1)
    bit_nonzero = seed[incoming_idx, :] .!= 0
    which_nonzero = (1:param_cnt)[bit_nonzero]
    idx = NTuple{n_way,Int8}(which_nonzero)
    values = NTuple{n_way,Int8}(seed[incoming_idx, bit_nonzero])
    push!(ad[idx], values)
end

ad


n_way = 2
arity = Int[2,2,3,2,3]
param_cnt = length(arity)
tt = tracker(n_way, param_cnt)
seed = [
    1 1 2 0 0;
    0 1 2 0 1;
]
initialize_tracker(tt, seed)
possible_combination_cnt = possible_combinations(n_way, arity)
total_combinations = sum(possible_combination_cnt .* arity)
coverage = zeros(Int,length(arity), maximum(arity))
coverage_by_parameter = sum(coverage, dims = 2)

function least_covered(coverage)
    argmin(vec(sum(coverage, dims = 2)))
end

p0_idx = least_covered(coverage)
p0_val = argmin(coverage[p0_idx, 1:arity[p0_idx]])

# Given a set of known values, with some unset (0),
given = [0 0 2 0 1]
# which next value maximizes the coverage? It could be that
# this is 3-way, and only 1 is known.
# For each combination, try it with the same other values but a
# different one of this value. See if it exists.
collect(Combinatorics.combinations([1,3,5,7], 2))

# Are all combinations covered?
# Which variable has the most combinations remaining to cover?
# Which value of this variable is most uncovered?
# Given a string of variable values, what value of this variable maximizes
#  uncovered sets -or if none- participates in the most uncovered sets.

# Pseudocode
# while not all combinations covered
#   take the variable with the most to cover
#   choose its value that's least covered
#   for i in 1:M
#     for next variable in a sample order
#       choose a value that's least covered, given previous values.

function next_multiplicative!(values, arity)
    carry = 1
    for slot_idx in length(values):-1:1
        values[slot_idx] += carry
        if arity[slot_idx] < values[slot_idx]
            values[slot_idx] = 1
            carry = 1
        else
            carry = 0
        end
    end
end
vv = [1,1,1]
nmarity = [2,3,2]
for i in 1:prod(nmarity)
    next_multiplicative!(vv, nmarity)
    print(vv)
end

# This represents possible coverage as a matrix, one column per parameter,
# zero if not used.
function all_combinations(arity, n_way)
    v_cnt = length(arity)
    indices = collect(combinations(1:v_cnt, n_way))
    combinations_cnt = total_combinations(arity, n_way)

    coverage = zeros(Int, combinations_cnt, v_cnt)
    idx = 1
    for indices_idx in 1:size(indices, 1)
        offset = indices[indices_idx]
        sub_arity = arity[offset]
        sub_cnt = prod(sub_arity)
        values = copy(sub_arity)
        for sub_idx in 1:sub_cnt
            next_multiplicative!(values, sub_arity)
            coverage[idx, offset] = values
            idx += 1
        end
    end
    coverage
end


function combination_histogram(allc, arity)
    width = maximum(arity)
    hist = zeros(Int, length(arity), width)
    for row_idx in 1:size(allc, 1)
        for col_idx in 1:width
            if allc[row_idx, col_idx] > 0
                hist[col_idx, allc[row_idx, col_idx]] += 1
            end
        end
    end
    hist
end



function most_to_cover(allc, row_cnt)
   argmax(vec(sum(allc[1:row_cnt, :] .!= 0, dims = 1)))
end

function coverage_by_parameter(allc, row_cnt)
    vec(sum(allc[1:row_cnt, :] .!= 0, dims = 1))
end
 
 
function coverage_by_value(allc, row_cnt, arity, param_idx)
    hist = zeros(Int, arity[param_idx] + 1)
    for row_idx in 1:row_cnt
        hist[allc[row_idx, param_idx] + 1] += 1
    end
    hist[2:end]
end

function most_common_value(allc, row_cnt, arity, param_idx)
    hist = zeros(Int, arity[param_idx] + 1)
    for row_idx in 1:row_cnt
        hist[allc[row_idx, param_idx] + 1] += 1
    end
    argmax(hist[2:end])
end

function most_matches_existing(allc, row_cnt, arity, existing, param_idx, n_way)
    @assert existing[param_idx] == 0
    param_cnt = length(arity)
    params_known = min(sum(existing != 0), n_way - 1)
    hist = zeros(Int, arity[param_idx])
    for row_idx in 1:row_cnt
        if allc[row_idx, param_idx] != 0
            match_cnt = 0
            for match_idx in 1:param_cnt
                if existing[match_idx] != 0 && allc[row_idx, match_idx] == existing[match_idx]
                    match_cnt += 1
                end
            end
            if match_cnt == params_known
                hist[allc[row_idx, param_idx]] += 1
            end
        end
    end
    hist
end


combination_number(n, m) = prod(n:-1:(n-n_way+1)) ÷ factorial(n_way)


function pairs_in_entry(entry, n_way)
    n = length(entry)
    ans = zeros(Int, combination_number(n, n_way), n)
    row_idx = 1
    for param_idx in combinations(1:length(entry), n_way)
        for col_idx in 1:n_way
            ans[row_idx, param_idx[col_idx]] = entry[param_idx[col_idx]]
        end
        row_idx += 1
    end
    ans
end


function add_coverage!(allc, row_cnt, n_way, entry)
    param_cnt = length(entry)

    covers = zeros(Int, combination_number(param_cnt, n_way))
    cover_cnt = 0
    for row_idx in 1:row_cnt
        match_cnt = 0
        for match_idx in 1:param_cnt
            if allc[row_idx, match_idx] == entry[match_idx]
                match_cnt += 1
            end
        end
        if match_cnt == n_way
            cover_cnt += 1
            covers[cover_cnt] = row_idx
        end
    end
    for cover_idx in 1:cover_cnt
        if row_cnt > 1
            save = allc[row_cnt, :]
            allc[row_cnt, :] = allc[covers[cover_idx], :]
            allc[covers[cover_idx], :] = save
            row_cnt -= 1
        else
            row_cnt -= 1
        end
    end
    row_cnt
end


function match_score(allc, row_cnt, n_way, entry)
    param_cnt = length(entry)
    cover_cnt = 0
    for row_idx in 1:row_cnt
        param_match_cnt = 0
        for match_idx in 1:param_cnt
            if allc[row_idx, match_idx] == entry[match_idx]
                param_match_cnt += 1
            end
        end
        if param_match_cnt == n_way
            cover_cnt += 1
        end
    end
    cover_cnt
end

function argmin_rand(rng, v)
    small = typemax(v[1])
    small_extra_cnt = 0
    small_idx = -1
    for i in 1:length(v)
        if v[i] < small
            small = v[i]
            small_extra_cnt = 0
            small_idx = i
        elseif v[i] == small
            small_extra_cnt += 1
        # else not the smallest.
        end
    end
    if small_extra_cnt == 0
        return small_idx
    else
        which = rand(rng, 1:(small_extra_cnt + 1))
        which_cnt = 1
        for s_idx in small_idx:length(v)
            if v[s_idx] == small
                if which_cnt == which
                    return s_idx
                end
                which_cnt += 1
            end
        end
    end
    return 0
end

argmin_rand(rng, [1,2,3,0,5])
argmin_rand(rng, [1,2,3,0,5, 0])
# argmin_rand([], rng)

n_way = 2
M = 50
arity = [2,3,2,3]
allc = all_combinations(arity, n_way)
remain = size(allc, 1)
combination_histogram(allc, arity)
combinations_per_value(arity, n_way)

most_common_value(allc, remain, arity, 1)
match_score(allc, remain, n_way, [1,1,1,1])

existing = [1, 0, 0, 1]
most_matches_existing(allc, remain, arity, existing, 2, 2)
pairs_in_entry([1,3,7,5], 2)
remain = add_coverage!(allc, remain, 2, [1,2,1,1])
allc
add_coverage!(allc, remain, 2, [1,2,1,2])

n_way = 2
M = 50
arity = [2,3,2,3]
allc = all_combinations(arity, n_way)
remain = size(allc, 1)
rng = Random.MersenneTwister(9234724)
maximum_match_score = combination_number(param_cnt, n_way)
param_cnt = length(arity)

trials = zeros(Int, M, param_cnt)
trial_scores = zeros(Int, M)
params = zeros(Int, param_cnt)
entry = zeros(Int, param_cnt)

for trial_idx in 1:M
    params[:] = 1:param_cnt
    params[1] = most_to_cover(allc, remain)
    params[params[1]] = 1
    params[2:end] = shuffle(rng, params[2:end])

    entry[:] .= 0
    entry[params[1]] = most_common_value(allc, remain, arity, params[1])
    for p_idx in 2:param_cnt
        candidate_values = most_matches_existing(allc, remain, arity, entry, params[p_idx], n_way)
        entry[params[p_idx]] = argmin_rand(rng, -candidate_values)
    end
    score = match_score(allc, remain, n_way, entry)
    trial_scores[trial_idx] = score
    trials[trial_idx, :] = entry
    if score == maximum_match_score
        break
    end
end
argmin_rand(rng, -trial_scores)

function n_way_coverage(arity, n_way, M, rng)
    param_cnt = length(arity)
    allc = all_combinations(arity, n_way)
    remain = size(allc, 1)
    maximum_match_score = combination_number(param_cnt, n_way)
    param_cnt = length(arity)

    # Array of arrays.
    coverage = Array{Array{Int64,1},1}()

    trials = zeros(Int, M, param_cnt)
    trial_scores = zeros(Int, M)
    params = zeros(Int, param_cnt)
    entry = zeros(Int, param_cnt)
    
    while remain > 0
        params[:] = 1:param_cnt
        param_coverage = coverage_by_parameter(allc, remain)
        params[1] = argmin_rand(rng, -param_coverage)
        params[params[1]] = 1
        for trial_idx in 1:M    
            params[2:end] = shuffle(rng, params[2:end])
            entry[:] .= 0
            candidate_params = coverage_by_value(allc, remain, arity, params[1])
            entry[params[1]] = argmin_rand(rng, -candidate_params)
            for p_idx in 2:param_cnt
                candidate_values = most_matches_existing(allc, remain, arity, entry, params[p_idx], n_way)
                entry[params[p_idx]] = argmin_rand(rng, -candidate_values)
            end
            score = match_score(allc, remain, n_way, entry)
            trial_scores[trial_idx] = score
            trials[trial_idx, :] = entry
        end
        chosen_idx = argmin_rand(rng, -trial_scores)
        if trial_scores[chosen_idx] > 0
            chosen_trial = trials[chosen_idx, :]
            remain = add_coverage!(allc, remain, n_way, chosen_trial)
            push!(coverage, chosen_trial)
        end
    end
    coverage
end


rng = Random.MersenneTwister(9234724)
arity = [2,3,2,3]
n_way = 2

M = 50
n_way_coverage(arity, 2, M, rng)
