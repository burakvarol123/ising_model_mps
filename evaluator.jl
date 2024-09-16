"""
This script is used for evaluating and plotting physical variables!
"""


using HDF5
using ITensors

include("./isingHamiltonian.jl")

function magnetization(
    lattice_size:: Int, 
    psi:: MPS
    )
    """
    Calculate <M_z^2>
    """
    
    os = OpSum()
    for i = 1 : lattice_size
        os += 1/lattice_size, "Sz", i
    end 
    sites = siteinds(psi)
    mag = MPO(os, sites)
    magnet = inner(psi', apply(mag,mag), psi)

    return magnet
end

function binder_cumulant(
    lattice_size:: Int,
    psi:: MPS,
    )
    """
    Calculate Binder Cumulant. The intersection of binder cumulants of different
    lengths shows the critical point!
    """
    os = OpSum()
    for i = 1 : lattice_size
        os += 1/lattice_size, "Sz", i
    end 
    sites = siteinds(psi)
    mag = MPO(os, sites)
    mag_2 = inner(psi', apply(mag,mag), psi)
    mag_4= inner(psi', apply(mag,apply(mag,apply(mag,mag))), psi)
    coef = 1- mag_4/3*mag_2^2
    return coef
end

function read_data(
    data::String,
    number_states :: Int
    )
    """
    Read the wavefunction MPS and energy from dmrg result. Number of states 
    is denoted as K in the code.
    """
    f= h5open(data,"r")
    wavefct = []
    for i in 1:number_states
        psi = read(f, "psi$i", MPS)
        push!(wavefct, psi)
    end
    energy = read(f, "energy", ITensor)
    return wavefct, energy
end

function make_plot(
    xlabel:: String,
    ylabel:: String,
    title:: String,
    x_data :: Any,
    y_data:: Any,
    savepath:: String,
    )
    """
    Plots the values, I just wrote this for a cleaner code
    """
    plot(x_data, y_data, marker=:circle)
    xlabel!(xlabel)
    ylabel!(ylabel)
    title!(title)
    savefig(savepath)  
end


if abspath(PROGRAM_FILE) == @__FILE__
    using Plots
    #Start evaluating magnetisation, gs energy and energy gap
    
    data_folder = "/Users/salsa/TensorNetworks/ising_model_mps/simulation_data/data"
    files = readdir(data_folder)
    ener = []
    ge = []
    fe=[]
    magnetisation =[]
    wavefunctions = []
    lattice_size = 100
    number_states = 4
    hdivJ = 0.1:0.1:2
    for file in files
        file_path = joinpath(data_folder, file)
        dataset = read_data(file_path, number_states)  
        push!(ener, dataset[2])
        push!(wavefunctions, dataset[1])
        println("Read datasets: " , file)
    end
    for energy in ener
        push!(ge, energy[1])
        push!(fe, energy[2])
    end
    #@show ener
    #exit() to show yibin the comparisons between energies of his script
    counter = 0
    for state in wavefunctions
        global counter
        counter += 1
        gs = state[1]
        magnet = magnetization(lattice_size, gs )
        push!(magnetisation, magnet)
        println("finished loop counter")
    end
    #Change the saving folder when you will use it
    make_plot("h/J", "Energy", "Ground State Energy, J=1", hdivJ, ge, "/Users/salsa/TensorNetworks/ising_model_mps/visuals/data/energy.png" )
    make_plot("h/J", "Energy Difference", "Ground State vs 1st Excited State, J=1", hdivJ, fe-ge, "/Users/salsa/TensorNetworks/ising_model_mps/visuals/data/energy_difference.png" )
    make_plot("h/J", "<Sum Sz^2>", "Magnetization^2", hdivJ, magnetisation, "/Users/salsa/TensorNetworks/ising_model_mps/visuals/data/magnetisationsz2.png" )


    #exit() exit if you dont want the binder cumulant. 
    #Start Binder cumulant, you might have to adjust the file names.
    binder_cumulants = Dict{String, Vector{Any}}()
    hdivJ = 0.0:0.1:2
    lattice_sizes = 50:50:250
    for size in lattice_sizes
        binder_cumulants["binder_cumulant_$size"] = []
        data_folder = "/Users/salsa/TensorNetworks/ising_model_mps/simulation_data/data_$size"
        files = readdir(data_folder)
        for file in files
            file_path = joinpath(data_folder, file)
            dataset = read_data(file_path, 2)  
            wavefunction = dataset[1]
            binder = binder_cumulant(size, wavefunction[1])
            push!(binder_cumulants["binder_cumulant_$size"], binder)
        end
        println("Finished:", data_folder)
        plot!( hdivJ, binder_cumulants["binder_cumulant_$size"], label= ["lenght = $size"], legend=:bottomright , marker =:circle)
        xlabel!("hdivJ")
        ylabel!("U")
        title!("Binder Cumulants")

    end
    savefig("/Users/salsa/TensorNetworks/ising_model_mps/visuals/binder_cumulant")   
end


