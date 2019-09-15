
@inline @inbounds function eom_mediated_link(u, p, t)
    ωx, ωy, ωz, k, l, m, c = (p...,)
    x₁, x₂, x₃, y₁, y₂, y₃, z₁, z₂, z₃ = (u...,)

    dx₁ = -ωx*x₂ - x₃ + c*(z₁ - x₁)
	dx₂ = ωx*x₁ + k*x₂
	dx₃ = l + x₃*(x₁ - m)

	dy₁ = -ωy*y₂ - y₃ + c*(z₁ - y₁)
	dy₂ = ωy*y₁ + k*y₂
	dy₃ = l + y₃*(y₁ - m)

	dz₁ = -ωz*z₂ - z₃
	dz₂ = ωz*z₁ + k*z₂
	dz₃ = l + z₃*(z₁ - m)

    SVector{9}(dx₁, dx₂, dx₃, dy₁, dy₂, dy₃, dz₁, dz₂, dz₃)
end

function mediated_link(u₀, ωx, ωy, ωz, k, l, m, c)
    p = [ωx, ωy, ωz, k, l, m, c]
    ContinuousDynamicalSystem(eom_mediated_link, u₀, p)
end

"""
    mediated_link(;u₀ = rand(9), ωx = 1, ωy = 1.015, ωz = 0.985,
        k = 0.15, l = 0.2, m = 10.0, 
        c = 0.06) -> ContinuousDynamicalSystem

Initialise a three-subsystem dynamical system where `X` and `Y` are
driven by `Z`. At the default value of the coupling constant `c = 0.06`, the
responses `X` and `Y` are already synchronized to the driver `Z`.

## Equations of motion

The equations of motion are 

```math
\\begin{aligned}
dx_1 &= -\\omega_x x_2 - x_3 + c*(z_1 - x_1) \\\\
dx_2 &= \\omega_x x_1 + k*x_2  \\\\
dx_3 &= l + x_3(x_1 - m)  \\\\
dy_1 &= -\\omega_y y_2 - y_3 + c*(z_1 - y_1)  \\\\
dy_2 &= \\omega_y y_1 + k*y_2  \\\\
dy_3 &= l + y_3(y_1 - m)  \\\\
dz_1 &= -\\omega_z z_2 - z_3  \\\\
dz_2 &= \\omega_z z_1 + k*z_2  \\\\
dz_3 &= l + z_3(z_1 - m)
\\end{aligned}
```

##  References

1. Krakovská, Anna, et al. "Comparison of six methods for the detection of 
    causality in a bivariate time series." Physical Review E 97.4 (2018): 042207
"""
mediated_link(;u₀ = rand(9), ωx = 1, ωy = 1.015, ωz = 0.985,
            k = 0.15, l = 0.2, m = 10.0, c = 0.06) =
    mediated_link(u₀, ωx, ωy, ωz, k, l, m, c)
