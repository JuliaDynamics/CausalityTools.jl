# The uncertainty handling framework in this file will be added
# as part of a 1.X release. Can be ignored for now.

using CausalityTools, UncertainData

n = 20

# Mean values for two time series x and y, and standard deviations for those values
vals_x, stds_x = rand(n), rand(n) * 0.1
vals_y, stds_y = rand(n), rand(n) * 0.1
vals_z, stds_z = rand(n), rand(n) * 0.1

# Represent values as normal distributions
uvals_x = [UncertainValue(Normal, vals_x[i], stds_x[i]) for i = 1:n]
uvals_y = [UncertainValue(Normal, vals_y[i], stds_y[i]) for i = 1:n]
uvals_z = [UncertainValue(Normal, vals_z[i], stds_z[i]) for i = 1:n]

X = UncertainValueStateSpaceSet(uvals_x)
Y = UncertainValueStateSpaceSet(uvals_y)
Z = UncertainValueStateSpaceSet(uvals_z)
