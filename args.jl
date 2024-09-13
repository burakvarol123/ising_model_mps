using ArgParse

function parse_commandline()
   s = ArgParseSettings()
   @add_arg_table s begin
       "--Dmax"
           help = "the maximum bond dimension of dmrg"
           arg_type = Int
           default = 100
       "--sweep_round"
           help = "the number of sweep round of dmrg"
           arg_type = Int
           default = 200
       "--weight"
           help = "the weight term constant used in dmrg"
           arg_type = Float64
           default = 100.0
       "--K"
           help = "the number of states calculated by dmrg"
           arg_type = Int
           default = 2
       "--folder"
           help = "where to store the results"
           default = "./data/"
       "--seed"
           arg_type = Int
           help = "random number seed"
           default = 42
       "--loadK"
           help = "load the loadK state"
           arg_type = Int
           default = 2
       "--initD"
           help = "initialize the state with bond dimension initD"
           arg_type = Int
           default = 20
       "--loadD"
           help = "load the state with bond dimension loadD"
           arg_type = Int
           default = 20
       "--loadLambda"
           help = "load the state with the cutoff of each bosonic Fock space"
           arg_type = Int
           default = 4
       "--WaveType"
           arg_type = String
           default = "random"
           help = "choose from [random, load_state]"
       "--lattice_size"
            arg_type = Int
            default = 5
        "--J"
            arg_type = Float64  
            default = 1.0
        "--hdivJ"
            arg_type = Float64
            default = 1.0 
    end
    return parse_args(s)
end
