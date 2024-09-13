using HDF5
using ITensors

include("./isingHamiltonian.jl")

function magnetization(
    lattice_size:: Int, 
    psi:: MPS,
    hdivJ:: Real,
    J::Real
    )
    
    os = OpSum()
    for i = 1 : lattice_size
        os += -hdivJ * J, "Sx", i
    end 
    sites = siteinds(psi)
    mag = MPO(os, sites)
    magnet = inner(psi', mag, psi)
    return magnet
end

function read_data(
    data::String,
    number_states :: Int
    )
    f= h5open(data,"r")
    wavefct = []
    for i in 1:number_states
        psi = read(f, "psi$i", MPS)
        push!(wavefct, psi)
    end
    energy = read(f, "energy", ITensor)
    return wavefct, energy
end

if abspath(PROGRAM_FILE) == @__FILE__
    using Plots
    counter = 0

    data_folder = "/Users/salsa/TensorNetworks/ising_model_mps/data_2"
    files = readdir(data_folder)
    ener = []
    ge = []
    fe=[]
    magnetisation =[]
    wavefunctions = []
    gs = []
    hdivJ = 0.1:0.1:2
    for file in files
        file_path = joinpath(data_folder, file)
        dataset = read_data(file_path, 2)  
        push!(ener, dataset[2])
        push!(wavefunctions, dataset[1])
        println("Read datasets: " , file)
    end
    for energy in ener
        push!(ge, energy[1])
        push!(fe, energy[2])
    end
    for state in wavefunctions
        push!(gs, state[1])
    end
    
    for state in gs
        global counter
        counter += 1
        magnet = magnetization(100, state,hdivJ[counter], 1 )
        push!(magnetisation, magnet)
        println("finished loop $counter")
    end
    
    xlabel!("h/J")
    ylabel!("magnetisation")
    plot(hdivJ,magnetisation)
    savefig("magnet.png")  

    xlabel!("h/J")
    ylabel!("energy")
    plot(hdivJ,ge )
    savefig("energy.png")

    xlabel!("h/J")
    ylabel!("energy difference")
    plot(hdivJ, fe-ge)
    savefig("difference.png")


end


