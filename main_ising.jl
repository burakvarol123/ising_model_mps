using ITensors
using HDF5
using Printf:@printf
import Random
include("./args.jl")
include("./setOperator.jl")
include("./initmps.jl")
include("./isingHamiltonian.jl")

function main()
  @show VERSION
  args = parse_commandline()
  println("Parsed args:")
  # Access the parsed arguments
  for (arg,val) in args
     println("  $arg  =>  $val")
  end
  lattice_size = args["lattice_size"]
  J = args["J"]
  hdivJ = args["hdivJ"]
  Dmax = args["Dmax"]
  weight = args["weight"]
  sweep_round = args["sweep_round"]
  K = args["K"]
  datapath = args["folder"]
  seed = args["seed"]

  os = ising(hdivJ, J, lattice_size)
  sites = siteinds("S=1/2", lattice_size)
  H = MPO(os, sites)

  oSzT = TotalSz(lattice_size)
  SzTMPO = MPO(oSzT, sites)

  Random.seed!(seed)
  psi_i = InitMPS(10, K, "random", sites)
  print(psi_i[1])

  ## Set parameters of sweeps
  #BondDims = [10, 20, 100, 200, 300, Dmax]
  BondDims = [10, 20, 40, Dmax]
  cutoff = [1e-10]
  noise = [1e-7, 1e-8, 1e-10, 0, 1e-11, 1e-10, 1e-9, 1e-11, 0]
  obs = DMRGObserver(["Sz"], sites, energy_tol=1.e-10, minsweeps=5, energy_type=Float64)

  println("Start Calculating Groud State!")
  temp_energy, temp_psi = dmrg(H, psi_i[1], nsweeps=sweep_round, maxdim=BondDims, mindim=20, cutoff=cutoff, noise=noise, eigsolve_krylovdim=9, observer=obs)
  norm = inner(temp_psi, temp_psi)
  energyn = inner(temp_psi', H, temp_psi)/norm
  tempSzT = inner(temp_psi', SzTMPO, temp_psi)/norm
  println("Observaties of the ground state after sweep. SzT = ", tempSzT, "; energy per site E = ", energyn/lattice_size)
  # Exact E0 in thermaldynamic limit: -0.4431472
  
  psi = [temp_psi]
  energy = [energyn]
  SzT = [tempSzT]

  for m = 2:K
    println("Start Calculating the $(m-1) Excited State!")
    temp_energy, temp_psi = dmrg(H, psi[1:m-1], psi_i[m]; nsweeps=sweep_round, maxdim=BondDims, mindim=20, cutoff=cutoff, noise=noise, weight=weight, eigsolve_krylovdim=9, observer=obs)
    norm = inner(temp_psi, temp_psi)
    energyn = inner(temp_psi', H, temp_psi)/norm
    tempSzT = inner(temp_psi', SzTMPO, temp_psi)/norm
    println("Observaties of the $(m-1) state after sweep. SzT = ", tempSzT, "; energy per site E = ", energyn/lattice_size)
    push!(psi, temp_psi)
    push!(energy, energyn)
    push!(SzT, tempSzT)
  end

  println("Heisenberg Model calculation, parameters: lattice_size = ", lattice_size ," J = ", J, ", Bond = ", Dmax)
  println("Energy E: ", energy)
  println("Total Sz expectation value: ", SzT)
  if K > 1
     psioverlap = inner(psi[2], psi[1])
     println("<psi_1|psi_0> = : ", psioverlap)
     GN = lattice_size*(energy[2]-energy[1])
     println("lattice_size  * Gap: ", GN)
  end

  ## make sure folder data exists
  println("datapath: ", datapath)
  if ispath(datapath)
	  println("folder data exists")
  else
	  mkdir(datapath)
	  println("folder data doesn't exist, creat it")
  end

  ## save results
  filename = string(datapath, "lattice_size", lattice_size, "J", J, "D", Dmax, "K", K,"hdivJ", hdivJ, ".h5")
  println("data save path: ", filename)
  f = h5open(filename, "w")
  for m = 1:K
    write(f,string("psi",m),psi[m])
  end

  i = Index(K,"i")
  write(f,"energy",ITensor(energy, i))
  write(f,"sites",sites)
  close(f)
  
  return
end

# Call the main function when the script is run
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end