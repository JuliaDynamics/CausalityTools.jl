import TimeseriesSurrogates: surrogenerator
using TimeseriesSurrogates: RandomShuffle, SurrogateGenerator

function surrogenerator(x::AbstractStateSpaceSet, rf::RandomShuffle, rng = Random.default_rng())
    n = length(x)

    init = (
        permutation = collect(1:n),
    )

    return SurrogateGenerator(rf, x, similar(x.data), init, rng)
end

function (sg::SurrogateGenerator{<:RandomShuffle, T})() where T<:AbstractStateSpaceSet
    x, s, rng = sg.x, sg.s, sg.rng
    n = length(x)
    permutation = getfield.(Ref(sg.init), (:permutation))
    shuffle!(rng, permutation)
    for i in 1:n
        s[i] = x[permutation[i]]
    end
    return T(s)
end
