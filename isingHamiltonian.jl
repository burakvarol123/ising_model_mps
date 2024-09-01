using ITensors

function ising(
    h:: Real, 
    J:: Real, 
    lattice_size :: Int
    )  

    #nearest neigbour
    os = OpSum()
    for i = 1: lattice_size - 1
        if i+1 < lattice_size
            os += -J,"Sz", i , "Sz", i+1
        end
    end
    #magnetisation
    for i = 1 : lattice_size
        os += -h, "Sx", i
    end 
    #@show os 
    return os 
end

if abspath(PROGRAM_FILE) == @__FILE__
    h, J , lattice_size = 1, 1 , 5
    ising(h,J,lattice_size)
end
