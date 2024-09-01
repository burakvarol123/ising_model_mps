import h5py
import numpy as np

def extract_datasets_from_h5(h5filename):
    data_dict = {}

    def recursive_visit(name, node):
        if isinstance(node, h5py.Dataset):
            data_dict[name] = node[()]
        elif isinstance(node, h5py.Group):
            for key, item in node.items():
                recursive_visit(f"{name}/{key}", item)

    with h5py.File(h5filename, 'r') as file:
        for key, item in file.items():
            recursive_visit(key, item)

    return data_dict

h5filename = '/Users/salsa/TensorNetworks/ising_model_mps/data/lattice_size5J1D100K4h1.h5'
data_dict = extract_datasets_from_h5(h5filename)
energy = data_dict["energy/storage/data"]
indices =data_dict["energy/storage/ind"]




    