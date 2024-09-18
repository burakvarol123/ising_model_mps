
1D Ising Model with Tensor Network

This project tries to simulate 1D Ising Model with MPS and DMRG:

![equation](https://latex.codecogs.com/svg.image?H=-J\sum_{<ij>}S_i^z&space;S_j^z-h\sum_i&space;S^x_i&space;)

You can find the magnetisation, energy, energy gap and binder cumulant graphs 
in the visuals folder. Critical value is seen at h/j = 0.5. Note that we have
an extra factor of 1/2 in h/J compared to the literature since pauli matrices are
defined here with a factor of 1/2.

Still in progres for more optimisation
