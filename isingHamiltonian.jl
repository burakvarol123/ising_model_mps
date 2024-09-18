using ITensors

function ising(
    hdivJ:: Float64, 
    J::Float64, 
    lattice_size :: Int
    )  

    #nearest neigbour
    os = OpSum()
    for i = 1: lattice_size 
        if i < lattice_size
            os += -J,"Sz", i , "Sz", i+1
        end
    end
    #magnetisation
    for i = 1 : lattice_size
        os += -hdivJ * J, "Sx", i
    end 
    #@show os 
    return os 
end

if abspath(PROGRAM_FILE) == @__FILE__
    #Little test
    hdivJ, J , lattice_size = 0.1, 1.0 , 5
    isingh= ising(hdivJ,J,lattice_size)
    @show isingh
end
