module Raven

using Adapt
using Compat
using GPUArraysCore
using KernelAbstractions
using KernelAbstractions.Extras: @unroll
using LinearAlgebra
using MPI
using OneDimensionalNodes
import P4estTypes
using RecipesBase
using StaticArrays
using StaticArrays: tuple_prod, tuple_length, size_to_tuple
using SparseArrays

export LobattoCell

export arraytype, floattype
export derivatives, facemass, mass, points, toequallyspaced
export derivatives_1d, points_1d, weights_1d, tohalves_1d
export referencecell, levels, trees, offset, numcells

export volumemetrics, surfacemetrics

export flatten, unflatten

export brick, coarsegrid

export GridManager, generate
export GridArray, components, sizewithghosts, viewwithghosts, parentwithghosts

export adapt!

include("orientation.jl")
include("arrays.jl")
include("sparsearrays.jl")
include("eye.jl")
include("flatten.jl")
include("cells.jl")
include("coarsegrids.jl")
include("communication.jl")
include("grids.jl")
include("gridmanager.jl")
include("gridarrays.jl")
include("kron.jl")

if !isdefined(Base, :get_extension)
    using Requires
end

@static if !isdefined(Base, :get_extension)
    function __init__()
        @require CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba" include(
            "../ext/RavenCUDAExt.jl",
        )
        @require WriteVTK = "64499a7a-5c06-52f2-abe2-ccb03c286192" include(
            "../ext/RavenWriteVTKExt.jl",
        )
    end
end

end # module Raven
