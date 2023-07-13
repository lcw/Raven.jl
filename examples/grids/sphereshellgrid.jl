using MPI

MPI.Initialized() || MPI.Init()

const comm = MPI.COMM_WORLD

using Raven
using WriteVTK
using StaticArrays

# here the level is a tuple to 
# coarsegrid = extrude(cubesphere(2, 2), 1)
# gm = GridManager(cell, coarsegrid; level = (2, 3))

N = (3, 3)
R = 1

coarse_grid = Raven.cubeshellgrid(R)

gm = GridManager(LobattoCell{Tuple{N...},Float64,Array}(), coarse_grid, min_level = 2)

indicator = rand((Raven.AdaptNone, Raven.AdaptRefine), length(gm))
adapt!(gm, indicator)

function stretch(point)
    return SVector(point[1], 3 * point[2], point[3])
end

grid = generate(stretch, gm)     #Example of user warp

vtk_grid("grid", grid) do vtk
    vtk["CellNumber"] = (1:length(grid)) .+ Raven.offset(grid)
    P = toequallyspaced(referencecell(grid))
    x = P * reshape(points(grid), size(P, 2), :)
    vtk["x"] = collect(x)
end
