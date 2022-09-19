abstract type AbstractGrid{C<:AbstractCell} end

floattype(::Type{<:AbstractGrid{C}}) where {C} = floattype(C)
arraytype(::Type{<:AbstractGrid{C}}) where {C} = arraytype(C)
celltype(::Type{<:AbstractGrid{C}}) where {C} = C

floattype(grid::AbstractGrid) = floattype(typeof(grid))
arraytype(grid::AbstractGrid) = arraytype(typeof(grid))
celltype(grid::AbstractGrid) = celltype(typeof(grid))

function WriteVTK.vtk_grid(filename::AbstractString, grid::AbstractGrid, args...; kwargs...)
    return pvtk_grid(filename, grid, args...; kwargs...)
end

function WriteVTK.pvtk_grid(
    filename::AbstractString,
    grid::AbstractGrid,
    args...;
    kwargs...,
)
    part = partitionnumber(grid)
    nparts = numberofpartitions(grid)
    vtk = pvtk_grid(
        filename,
        points_vtk(grid),
        cells_vtk(grid),
        args...;
        part,
        nparts,
        kwargs...,
    )
    data_vtk!(vtk, grid)

    return vtk
end

struct Grid{C<:AbstractCell,P,L,T} <: AbstractGrid{C}
    part::Int
    nparts::Int
    cell::C
    offset::Int
    points::P
    levels::L
    trees::T
end

referencecell(grid::Grid) = grid.cell
points(grid::Grid) = grid.points
levels(grid::Grid) = grid.levels
trees(grid::Grid) = grid.trees
offset(grid::Grid) = grid.offset
Base.length(grid::Grid) = last(size(grid.points))
partitionnumber(grid::Grid) = grid.part
numberofpartitions(grid::Grid) = grid.nparts

function points_vtk(grid::Grid)
    P = toequallyspaced(referencecell(grid))
    x = P * reshape(points(grid), size(P, 2), :)

    return reinterpret(reshape, floattype(grid), vec(adapt(Array, x)))
end

function cells_vtk(grid::Grid)
    type = celltype_vtk(referencecell(grid))
    connectivity = connectivity_vtk(referencecell(grid))

    cells = [
        MeshCell(type, e * length(connectivity) .+ connectivity) for e = 0:(length(grid)-1)
    ]

    return cells
end

function data_vtk!(vtk, grid::Grid)
    higherorderdegrees = zeros(Int, 3, length(grid))
    ds = [degrees(referencecell(grid))...]
    higherorderdegrees[1:length(ds), :] .= repeat(ds, 1, length(grid))

    vtk["HigherOrderDegrees", VTKCellData()] = higherorderdegrees
    vtk[VTKCellData()] = Dict("HigherOrderDegrees" => "HigherOrderDegrees")

    vtk["PartitionNumber", VTKCellData()] = fill(partitionnumber(grid), length(grid))
    vtk["Level", VTKCellData()] = collect(levels(grid))
    vtk["Tree", VTKCellData()] = collect(trees(grid))

    return
end
