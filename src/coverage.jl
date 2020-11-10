using Combinatorics

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
# For instance, [2,3,4]. it would be [7, 6, 5] for 2-way. Which means total combinations are [14, 12, 10].
function possible_combinations(n_way, param_size)
    param_cnt = length(param_size)
    combinations = zeros(Int, param_cnt)
    # param_keys = [NTuple{n_way,Int8}(x) for x in collect(Combinatorics.combinations(1:param_cnt, n_way))]
    param_keys = [x for x in collect(Combinatorics.combinations(1:param_cnt, n_way))]
    for comb_idx in 1:param_cnt
        factor = param_size[comb_idx]
        total = sum([prod(param_size[key_set]) / factor for key_set in param_keys if comb_idx in key_set])
        combinations[comb_idx] = total
    end
    combinations
end

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
collect(Combinatorics.combinations([1,3,5], 2))

# Pseudocode
# while not all combinations covered
#   take the variable with the most to cover
#   choose its value that's least covered
#   for i in 1:M
#     for next variable in a sample order
#       choose a value that's least covered, given previous values.


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

