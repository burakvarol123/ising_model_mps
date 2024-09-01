function TotalSz(lattice_size::Int)
    """
    This function is used to generate the observation operator for total Sz
    N: the number of sites
    oSz: the observation operator for total Sz
    """
    oSz = OpSum()
    for n=1:lattice_size
        oSz += 1.,"Sz",n
    end
    return oSz
end


if abspath(PROGRAM_FILE) == @__FILE__
    using ITensors
    lattice_size = 2
    oSz = TotalSz(lattice_size)
    @show oSz
    @show length(oSz)
end