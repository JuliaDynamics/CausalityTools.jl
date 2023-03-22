using HypothesisTests: OneSampleZTest, pvalue
using ShiftedArrays
using DelayEmbeddings: estimate_delay
using Statistics: median, mean
using Combinatorics: combinations

export OptimalAsymmetry
# TODO: does one even need to make the embeddings completely symmetric? isn't it enough
# to just test *one* time step in the non-causal direction?
"""
    OptimalAsymmetry(τmax = 5, m::Int = 5, α = 0.05, est = FPVP(), k = 1)

The optimal predictive asymmetry algorithm (`OptimalAsymmetry`) for inferring causal graphs.

## Description

Assumes two inputs: a timeseries ``X^{(i)}``, and a set of candidate timeseries
``X^{(k)}_{k=1}^r`` that potentially influences ``X^{(i)}``.

Under the assumption that the random variable ``X^{(i)}`` is driven by its own past,
the OptimalAsymmetry algorithm attempts to quantify if any other input variables ``X^{(j)}``
influences ``X^{(i)}`` by:

1. Computing the pairwise predictive asymmetry distribution with with respect to ``X^{(i)}``
    for all ``X^{(j)} \\in X^{(k)}_{k=1}^r``. Select the variable ``X^{(j)}`` that has
    the highest significant asymmetry  (i.e. the associated p-value is
    below `α`). If an ``X^{(j)}`` is found, it is added to the set of already selected
    parents ``\\mathcal{P}^{(i)}`` for ``X^{(j)}``.
2. Perform conditional OptimalAsymmetry, finding the parent
    `Pₖ` that has the highest association with ``X^{(i)}`` given ``X^{(i)}``'s past
    and the already selected parents.
3. Repeat until no more variables with significant association are found.
"""
Base.@kwdef struct OptimalAsymmetry{MP, MC, A, K, EP, EC, N}
    τmax::Int = 0
    m::Int = 6
    α::A = 0.05
    k::K = 1.0 # exponential decay constant
    measure_pairwise::MP = MIShannon()
    measure_cond::MC = CMIShannon()
    est_pairwise::EP = KSG2()
    est_cond::EC = FPVP()
    n_bootstrap::N = 3000
    # TODO: maximum number of conditional discoveries.
    f::Function = mean
end

function infer_graph(alg::OptimalAsymmetry, x; verbose = false)
    parents = select_parents(alg, x; verbose)
    return parents
end

"""
    select_parents(alg::OptimalAsymmetry, x)

The parent selection step of the [`OptimalAsymmetry`](@ref) algorithm, which identifies the
parents of each `xᵢ ∈ x`, assuming that `x` must be integer-indexable, i.e.
`x[i]` yields the `i`-th variable.
"""
function select_parents(alg::OptimalAsymmetry, x; verbose = false)
    parents = [select_parents(alg, x, k; verbose) for k in eachindex(x)]
    return parents
end


Base.@kwdef mutable struct OptimalAsymmetrySelectedParents{P, PJ, PT}
    i::Int
    parents::P = Vector{Vector{eltype(1.0)}}(undef, 0)
    js::PJ = Vector{Int}(undef, 0)
    τs::PT = Vector{Int}(undef, 0)
end


function selected(o::OptimalAsymmetrySelectedParents)
    js, τs = o.js, o.τs
    @assert length(js) == length(τs)
    return join(["x$(js[i])($(τs[i]))" for i in eachindex(js)], ", ")
end

# TODO: make a variant that first both pairwise and conditional
# checks without significance testing, then
# performs gradually descending PA signifiacnce testing until significant case is found.

function Base.show(io::IO, x::OptimalAsymmetrySelectedParents)
    s = ["x$j($τ)" for (j, τ) in zip(x.js, x.τs)]
    if isempty(x.js)
        all = "x$(x.i)(0) ← ∅"
    else
        all = "x$(x.i)(0) ← $(join(s, ", "))"
    end
    show(io, all)
end

# TODO:
# Optimise first step by perhaps computing raw mutul information. First,
# find the variable that maximizes MI, then run a cascade of signifiacnce
# tests (using asymmetry) until a significant variable is selected.

function select_parents(alg::OptimalAsymmetry, x, i::Int; verbose = false)
    (; τmax, m, α, k, measure_pairwise, measure_cond, est_pairwise, est_cond, n_bootstrap, f) = alg

    verbose && println("\n=======================================")
    verbose && println("Finding parents for variable x$i ....")
    verbose && println("=======================================")

    # Nodes can be self-causal
    idxs = 1:length(x) # setdiff(1:length(x), i)
    js = Int[]
    τs = Int[]
    for j in idxs
        if j == i # it makes no sense to compare xi(0) to xi(0), or does it? depends on..
            # Because nodes can be self-causal and the zero lag is never included in the
            # Y⁺/Y^-, this is valid
            #append!(τs, 1:τmax)
            #append!(js, repeat([j], τmax))
        else
            append!(τs, 0:τmax)
            append!(js, repeat([j], τmax + 1))
        end
    end

    # These are modified in-place during the selection process.
    parents = OptimalAsymmetrySelectedParents(i = i)

    ###################################################################
    # Forward search
    ###################################################################
    # 1. Can we find a significant pairwise association?
    verbose && println("˧ Querying for pairwise directional association...")

    significant_pairwise = select_first_parent!(alg, parents, x, i, js, τs; verbose)
    if significant_pairwise
        verbose && println("˧ Querying new variables conditioned on already selected variables...")
        # 2. Continue until there are no more significant conditional pairwise associations
        significant_cond = true
        k = 0
        while significant_cond
            k += 1
            significant_cond = select_conditional_parent!(alg, parents, x, i, js, τs; verbose)
        end


        verbose && println("˧ Backwards elimination...")
        # The last added variables are probably more likely to be removed, so we
        # reverse the order in which we check the variables.
        idxs_vars_remaining = reverse(1:length(parents.js) |> collect)

        eliminate = true
        while eliminate && length(idxs_vars_remaining) >= 2
            for q in idxs_vars_remaining
                #TODO perhaps do the backwards check while doing forward search?
                eliminate = backwards_eliminate!(alg, parents, x, i, q, idxs_vars_remaining; verbose)
                if eliminate
                    deleteat!(idxs_vars_remaining, q)
                end
                eliminate && break
            end
        end
    end

    return parents
end

# Strategy
# Find the variable that maximizes MI
# Then perform asymmetry-based significance testing to find the first variable
# that has significant.
function select_first_parent!(alg::OptimalAsymmetry, parents, x, i::Int, js, τs; verbose = false)
    (; τmax, m, α, k, measure_pairwise, measure_cond, est_pairwise, est_cond, n_bootstrap, f) = alg
    xᵢ = x[i]
    # Generate all candidates
    @assert length(τs) == length(js)

    pairwise_I = zeros(length(τs))
    for (l, (j, τ)) in enumerate(zip(js, τs))
        pairwise_I[l] = estimate(measure_pairwise, est_pairwise, x[j], xᵢ)
    end

    sort_idxs = sortperm(pairwise_I, rev = true)
    for ix in sort_idxs
        test = AsymmetryTest(measure_pairwise, est_pairwise;
            τS = τs[ix], condition_on_target = false, n_bootstrap, f)
        result = independence(test, x[js[ix]], xᵢ) # condition on unlagged xᵢ
        if pvalue(result) < α &&  mean(result.Δ) > 0
            verbose && println("  x$i(0) ← x$(js[ix])($(τs[ix]))")
            push!(parents.js, js[ix])
            push!(parents.τs, τs[ix])
            deleteat!(js, ix)
            deleteat!(τs, ix)
            return true
        end
    end

    # We found no significant pairwise associations
    s = ["x$i(0) ⇍ x($j) | ∅" for j in filter(j -> j != i, js)]
    verbose && println("  $(join(s, "\n  "))")
    return false
end

function select_conditional_parent!(alg::OptimalAsymmetry, parents, x, i::Int, js, τs; verbose = false)
    (; τmax, m, α, k, measure_pairwise, measure_cond, est_pairwise, est_cond, n_bootstrap, f) = alg
    @assert length(parents.js) == length(parents.τs)
    xᵢ = x[i]
    N = length(xᵢ)

    # Account for circularly shifting the data.
    maxlag = maximum([parents.τs; alg.m])
    idxs = (maxlag + 1):(N - maxlag)

    C⁻, C⁺ = lag_for_asymmetry(x, parents.τs, parents.js)
    conditional_Is = zeros(length(τs))
    for (l, (j, τ)) in enumerate(zip(js, τs))
        X⁻, X⁺ = lag_for_asymmetry(x[j], τ)
        conditional_Is[l] = dispatch(measure_cond, est_cond, X⁻[idxs], xᵢ[idxs], C⁻[idxs])
    end

    sort_idxs = sortperm(conditional_Is, rev = true)

    Δs = zeros(m) # allocating outside is fine, because we overwrite.
    fws = zeros(m) # allocating outside is fine, because we overwrite.

    for ix in sort_idxs
        if conditional_Is[ix] < 0
            s = ["x$i(1) ⇍ x$j($τ) | $(selected(parents))" for (τ, j) in zip(τs, js)]
            verbose && println("  $(join(s, "\n  "))")
            continue
        end
        # Compute asymmetry for the variable with currently highest association with the target.
        X⁻, X⁺ = lag_for_asymmetry(x[js[ix]], τs[ix])
        for i in 1:m
            Yⁿ⁻, Yⁿ⁺ = lag_for_asymmetry(xᵢ, [0, abs(i)])
            fw = @views dispatch(measure_cond, est_cond, X⁻[idxs], Yⁿ⁺[idxs], C⁻[idxs])
            bw = @views dispatch(measure_cond, est_cond, X⁺[idxs], Yⁿ⁻[idxs], C⁺[idxs])
            Δs[i] = fw - bw
            fws[i] = fw
        end

        # Check for significance.
        result = bootstrap_right(f, Δs, 0.0; n = n_bootstrap)
        if pvalue(result) < α
            verbose && println("  x$i(0) ← x$(js[ix])($(τs[ix]))")
            push!(parents.js, js[ix])
            push!(parents.τs, τs[ix])
            deleteat!(js, ix)
            deleteat!(τs, ix)
            return true
        end
    end
    # No significant links were found.
    s = ["x$i(1) ⇍ x$j($τ) | $(selected(parents)))" for (τ, j) in zip(τs, js)]
    verbose && println("  $(join(s, "\n  "))")
    return false
end


function backwards_eliminate!(alg::OptimalAsymmetry, parents, x, i::Int, q::Int, idxs_vars_remaining; verbose = false)
    (; τmax, m, α, k, measure_pairwise, measure_cond, est_pairwise, est_cond, n_bootstrap, f) = alg
    M = length(parents.js)

    js_remaining = parents.js[setdiff(1:M, q)]
    τs_remaining = parents.τs[setdiff(1:M, q)]
    if isempty(js_remaining) || q > length(parents.js)
        return false
    end
    xᵢ = x[i]
    # Account for circularly shifting the data.
    maxlag = maximum([parents.τs; m])
    idxs = (maxlag + 1):(length(xᵢ) - maxlag)

    # See if x becomes independent of the target, given some subset of the other parents,
    # on conditioning sets of gradually increasing size, starting from 1.
    X⁻, X⁺ = lag_for_asymmetry(x[parents.js[q]], parents.τs[q])
    Y⁻, Y⁺ = lag_for_asymmetry(xᵢ, 0:1)

    max_combolength = length(js_remaining)

    for cl in 1:max_combolength
        combs = combinations(1:max_combolength, cl) |> collect # returns combinations of increasing size

        # Pre-compute raw forward CMI (can be done per conditioning set size too for speed-up)
        conditional_Is = zeros(length(combs))

        for (k, comb) in enumerate(combs)
            C⁻, C⁺ = lag_for_asymmetry(x, τs_remaining[comb], js_remaining[comb])
            conditional_Is[k] = dispatch(measure_cond, est_cond, X⁻[idxs], xᵢ[idxs], C⁻[idxs])
        end

        sort_idxs = sortperm(conditional_Is, rev = true)
        Δs = zeros(m) # allocating outside is fine, because we overwrite.
        fws = zeros(m) # allocating outside is fine, because we overwrite.
        bws = zeros(m) # allocating outside is fine, because we overwrite.
        for ix in sort_idxs
            comb = combs[ix]
            if conditional_Is[ix] < 0
                j, τ = parents.js[q], parents.τs[q]
                s = join(["x$j($τ)" for (j, τ) in zip(js_remaining[comb], τs_remaining[comb])], ", ")
                r = "Keeping x$j($τ) in parent set"
                verbose && println("  x$i(0) ← x$j($τ) | $s ... $r")
                continue
            end
            C⁻, C⁺ = lag_for_asymmetry(x, τs_remaining[comb], js_remaining[comb])
            for i in 1:m
                Yⁿ⁻, Yⁿ⁺ = lag_for_asymmetry(xᵢ, abs(i))
                fw = @views dispatch(measure_cond, est_cond, X⁻[idxs], Yⁿ⁺[idxs], C⁻[idxs])
                bw = @views dispatch(measure_cond, est_cond, X⁺[idxs], Yⁿ⁻[idxs], C⁺[idxs])
                Δs[i] = fw - bw
                fws[i] = fw
                bws[i] = bw
            end

            # If p-value >= α, then we can't reject the null, i.e. the statistic I is
            # indistinguishable from zero, so we claim independence.
            test = bootstrap_right(f, Δs, 0.0; tail = :right)
            if pvalue(test) >= alg.α# || mean(fws) < 0
                j = parents.js[q]
                τ = parents.τs[q]
                r = "Removing x$j($τ) from parent set"
                s = join(["x$j($τ)" for (j, τ) in zip(js_remaining[comb], τs_remaining[comb])], ", ")
                verbose && println("  x$i(0) ⇍ x$j($τ) | $s ... $r")
                deleteat!(parents.js, q)
                deleteat!(parents.τs, q)
                return true # a variable was removed
            else
                # Keeping all parents...
                j = parents.js[q]
                τ = parents.τs[q]
                s = join(["x$j($τ)" for (j, τ) in zip(js_remaining[comb], τs_remaining[comb])], ", ")
                r = "Keeping x$j($τ) in parent set"
                verbose && println("  x$i(0) ← x$j($τ) | $s ... $r")
            end
        end
    end
    return false
end
