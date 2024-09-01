function InitMPS(D::Int, 
    K::Int, 
    WaveType::String, 
    sites::Vector{Index{Int64}})
    psi = []
   
    if WaveType == "random"
       println("start with random states")
       for m = 1:K
           psi_m = randomMPS(sites,D)
           push!(psi, psi_m)
       end
    end
    # ask yibin about load_state
    return psi
end
