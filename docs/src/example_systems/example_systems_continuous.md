
# [Continuous coupled dynamical systems](@id continuous_systems)

## Mediated link

```@docs
mediated_link(;u₀ = rand(9), ωx = 1, ωy = 1.015, ωz = 0.985,
    k = 0.15, l = 0.2, m = 10.0, c = 0.06)
```

## Two bidirectionally coupled Lorenz-Lorenz systems

```@docs
lorenz_lorenz_bidir(; u0 = rand(6),
        c_xy = 0.2, c_yx = 0.2,
        a₁ = 10, a₂ = 28, a₃ = 8/3,
        b₁ = 10, b₂ = 28, b₃ = 9/3)
```

## Two bidirectionally coupled 3D Lorenz systems forced by another 3D Lorenz system

```@docs
lorenz_lorenz_lorenz_bidir_forced(; u0 = rand(9),
        c_xy = 0.1, c_yx = 0.1,
        c_zx = 0.05, c_zy = 0.05,
        a₁ = 10, a₂ = 28, a₃ = 8/3,
        b₁ = 10, b₂ = 28, b₃ = 8/3,
        c₁ = 10, c₂ = 28, c₃ = 8/3)
```

## Two bidirectionally coupled 3D Rössler systems

```@docs
rossler_rossler_bidir(; u0 = rand(6),
        ω₁ = 1.015, ω₂ = 0.985,
        c_xy = 0.1, c_yx = 0.1,
        a₁ = 0.15, a₂ = 0.2, a₃ = 10,
        b₁ = 0.15, b₂ = 0.2, b₃ = 10)
```

## Two bidirectionally coupled 3D Rössler systems forced by another 3D Rössler system

```@docs
rossler_rossler_rossler_bidir_forced(; u0 = rand(9),
        ω₁ = 1.015, ω₂ = 0.985, ω₃ = 0.95,
        c_xy = 0.1, c_yx = 0.1,
        c_zx = 0.05, c_zy = 0.05,
        a₁ = 0.15, a₂ = 0.2, a₃ = 10,
        b₁ = 0.15, b₂ = 0.2, b₃ = 10,
        c₁ = 0.15, c₂ = 0.2, c₃ = 10)
```