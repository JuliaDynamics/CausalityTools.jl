using DynamicalSystems
using CausalityTools
using Plots
plotlyjs()

s = DynamicalSystems.Systems.coupledstandardmaps(2)
ts_length = 500
orbit = trajectory(s, ts_length - 1, Ttr = 1000)
x1, x2, y1, y2 = ([orbit[:, i] for i = 1:4]...,)


px = plot(x1, label = "x1", lc = :blue)
plot!(x2, label = "x2", lc = :blue, ls = :dash)
ylabel!("Value")

py = plot(y1, label = "y1", lc = :green)
plot!(y2, label = "y2", lc = :green, ls = :dash)
xlabel!("Time step")
ylabel!("Value")

plot(px, py, layout = (2, 1))


E = StateSpaceReconstruction.embed([x1, x2, y2], [1, 2, 3], [0, -10, -5])
E1, E2, E3 = ([E.points[i, :] for i = 1:3]...,)
scatter(E1, E2, E3, legend = false)

using RecipesBase
@recipe function f(E::StateSpaceReconstruction.AbstractEmbedding; vars = [1, 2, 3],
        mc = :black, ms = 2, lc = :black, lw = 1)
    if size(E.points, 1) < 3
        error("Cannot plot reconstruction with < 3 variables.")
    end
    legend --> false
    xlabel --> "x1"
    ylabel --> "x2"
    zlabel --> "x3"
    markercolor --> mc
    markersize --> ms
    ([E.points[i, :] for i in vars]...,)
end

scatter(E, ms = 0.5)

#########################################################
# Helper functions to plot 3D rectangles.
#########################################################
"""
    rectangle3dpts(x, y, z, ϵx, ϵy, ϵz)

Compute the coordinates of the vertices of a 3D rectangle, given the
coordinates of the origin (`x`, `y`, and `z`) and the corresponding edge lengths
(`ϵx`, `ϵy`, `ϵz`).
"""
function rectangle3dpts(x, y, z, ϵx, ϵy, ϵz)
    v1b = [x,    y,    z]
    v2b = [x+ϵx, y,    z]
    v3b = [x+ϵx, y+ϵy, z]
    v4b = [x,    y+ϵy, z]
    v1t = [x,    y,    z+ϵz]
    v2t = [x+ϵx, y,    z+ϵz]
    v3t = [x+ϵx, y+ϵy, z+ϵz]
    v4t = [x,    y+ϵy, z+ϵz]
    (v1b, v2b, v3b, v4b, v1t, v2t, v3t, v4t)
end

"""
    rectangle3dpts(o, ϵ)

Given the origin `o` (3-element vector) and edge lengths `ϵ` (also a
3-element vector) of a 3D rectangle, return the coordinates of its
vertices.
"""
function rectangle3dpts(o, ϵ)
    x, y, z = (o...,)
    ϵx, ϵy, ϵz = (ϵ...,)
    rectangle3dpts(x, y, z, ϵx, ϵy, ϵz)
end

"""
    connectvertices(o, ϵ)

Given the origin `o` (3-element vector) and edge lengths `ϵ` (also a
3-element vector) of a 3D rectangle, return a vector of line segments
(each a dim-by-n_vertices array) that when plotted together yields
the entire rectangle.
"""
function connectvertices(o, ϵ)
    # Get the vertices
    v1b, v2b, v3b, v4b, v1t, v2t, v3t, v4t = rectangle3dpts(o, ϵ)

    # Connect vertices in top and bottom planes
    connect_top = zeros(3, 5)
    connect_bottom = zeros(3, 5)

    # Connect corners of the top and bottom planes
    corner1 = zeros(3, 2)
    corner2 = zeros(3, 2)
    corner3 = zeros(3, 2)
    corner4 = zeros(3, 2)
    connect_bottom[:, 1:5] = [v1b v2b v3b v4b v1b]
    connect_top[:, 1:5]    = [v1t v2t v3t v4t v1t]
    corner1[:, 1:2] = [v1b v1t]
    corner2[:, 1:2] = [v2b v2t]
    corner3[:, 1:2] = [v3b v3t]
    corner4[:, 1:2] = [v4b v4t]

    return [connect_top, connect_bottom,
            corner1, corner2, corner3, corner4]
end

"""
    splitaxes(x)

Return a vector of the individual components of an array of points
provided as an array where each point is a column.
"""
splitaxes(x) = ([x[k, :] for k = 1:size(x, 1)]...,)

"""
    plot_3D_rect!(p, origin, edgelengths;
             lc = :black, lw = 1.0, ls = :solid)

Append a a 3D rectangle to an existing plot `p`, given the
origin `o` (3-element vector) and edge lengths
`ϵ` (3-element vector) of the rectangle.
"""
function plot_3D_rect!(p, o, ϵ;
             lc = :black, lw = 1.0, ls = :solid, lα = 0.7)

    linesegments = connectvertices(o, ϵ)
    for segment in linesegments
        plot!(p, splitaxes(segment),
            lc = lc, lw = lw, ls = ls, lα = lα)
    end
end

"""
Given the `origin` of a hyperrectangle and the `stepsizes` along each
coordinate axis, divide each axis into `N` stepsizes starting
from `origin[i] + (stepsizes[i]/N)/2`
"""
function fill_hyperrectangle_3D(origin, stepsizes, N = 10)
    xs, ys, zs = ([LinRange(origin[i] + stepsizes[i]/N/2, origin[i] + stepsizes[i] - stepsizes[i]/N/2, N) for i = 1:length(origin)]...,)
    pts = zeros(Float64, 3, length(xs)^3)
    i = 0
    for x in xs
        for y in ys
            for z in zs
                i += 1
                pts[:, i] = [x, y, z]
            end
        end
    end
    pts
end


@recipe function f(N, riv::RectangularInvariantMeasure;
        lw = 0.8, lc = :black, lα = 0.5, ls = :do,
        ms = 0.2, mc = :black, mα = 0.3)

    pts = riv.E.points
    ϵ = riv.ϵ
    axisminima, stepsizes = minima_and_stepsizes(pts, ϵ)

    # All bins are assigned a bin origin.
    v = unique(riv.visited_bins_coordinates, dims = 2)

    # Bins may be visited by several times, so we'll get rid
    # of the repetitions.
    n_visited_boxes = size(v, 2)
    D = size(v, 1)

    # Plot the partition grid over the points of the reconstructed
    # orbit.
    legend --> false

    for i = 1:n_visited_boxes
        origin = riv.visited_bins_coordinates[:, i]
        # Get the measure of the box, and fill the box with a
        # number of points scaled to the measure.
        μ = riv.measure.dist[i] * 50
        fillpts = fill_hyperrectangle_3D(origin, stepsizes, N)
        @series begin
            seriestype := :scatter3d
            markersize --> μ/2
            markeralpha --> μ
            markercolor --> mc
            linecolor --> mc
            fillcolor --> :transparent
            splitaxes(fillpts)
        end

        linesegments = connectvertices(origin, stepsizes)

        for segment in linesegments
            @series begin
                seriestype := :path
                linealpha --> lα
                linewidth --> lw
                linecolor --> lc
                splitaxes(segment)
            end
        end
    end
end

@recipe function f(r::RectangularBinningTransferOperator)
    seriestype  :=  :heatmap
    xlabel --> "state #i"
    ylabel --> "state #j"
    r.transfermatrix
end

@recipe function f(id::InvariantDistribution)
    seriestype  :=  :bar
    xlabel --> "state # (i)"
    ylabel --> "invariant density"
    linecolor --> :black
    fillcolor --> :black
    fillalpha --> 0.5
    legend --> :none
    id.dist
end

@recipe function plot_grid(pts::AbstractArray{T, 2}, riv::RectangularInvariantMeasure; N = 5,
        lw = 0.8, lc = :black, lα = 0.5, ls = :do,
        ms = 0.2, mc = :black, mα = 0.3) where {T}

    axisminima, stepsizes = minima_and_stepsizes(pts, riv.ϵ)

    # All bins are assigned a bin origin.
    v = unique(riv.visited_bins_coordinates, dims = 2)

    # Bins may be visited by several times, so we'll get rid
    # of the repetitions.
    n_visited_boxes = size(v, 2)
    D = size(v, 1)

    # Plot the partition grid over the points of the reconstructed
    # orbit.
    legend --> false

    for i = 1:n_visited_boxes
        origin = riv.visited_bins_coordinates[:, i]
        # Get the measure of the box, and fill the box with a
        # number of points scaled to the measure.
        μ = riv.measure.dist[i]

        println(ceil(Int, μ*100))
        fillpts = fill_hyperrectangle_3D(origin, stepsizes, ceil(Int, μ*100))
        @series begin
            seriestype := :scatter3d
            markersize --> μ
            markeralpha --> μ
            markercolor --> mc
            linecolor --> mc
            fillcolor --> mc
            splitaxes(fillpts)
        end

        linesegments = connectvertices(origin, stepsizes)

        for segment in linesegments
            @series begin
                seriestype := :path
                linealpha --> lα
                linewidth --> lw
                linecolor --> lc
                splitaxes(segment)
            end
        end
    end
end


invm = rectangularinvariantmeasure(E, 4)

gr()
p1 = plot(invm.transfermatrix);
p2 = plot(invm.measure);
p3 = scatter(E, ms = 1.0);
p4 = plot(5, invm, lα = 0.2, ls = :dot,
                    ms = 0.5, mα = 0.5, mc = :blue);

plot(plot(p1, p2, link = :x, layout = (2, 1)),
    plot(p3, p4, layout = (2, 1)), layout = (1, 2))
savefig("docs/src/scripts/test.pdf")
