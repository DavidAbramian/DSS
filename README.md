# DSS

Matlab toolbox for diffusion-informed spatial smooting of fMRI data in white matter. This toolbox was created for the following [paper](https://doi.org/10.1016/j.neuroimage.2021.118095) (also available in [bioRxiv](https://www.biorxiv.org/content/10.1101/2020.10.25.353920v3)):

> Abramian, D., Larsson, M., Eklund, A., Aganj, I., Westin, C.F. and Behjat, H., 2021. Diffusion-informed spatial smoothing of fMRI data in white matter using spectral graph filters. Neuroimage, p.118095.

### Software prerequisits

- [Matlab](https://se.mathworks.com/products/matlab.html)
- [SPM toolbox](https://www.fil.ion.ucl.ac.uk/spm/): used for loading and saving NIfTI volumes.
- [DSI Studio](http://dsi-studio.labsolver.org/): used for generating diffusion ODFs from DWI data.

### Setup

1. Install SPM and add it to your Matlab path.
2. Install DSI Studio.
3. Download and extract DSS. Add to your Matlab path the code folder and all subfolders.
4. DSI Studio is used from Matlab through `system` calls. The path of the DSI Studio executable has to be provided in the `DSI_STUDIO_PATH` environmental variable. This can be set manually outside Matlab, but the easiest way is to do it from Matlab. Modify the provided `setup_dsi.m` function to have the path point to your DSI Studio executable, and make sure to run this function before using DSS every time Matlab is started. The process can be automated by calling this function from the `startup.m` script.

### Usage

The main function of the toolbox is `run_dss.m`:
```matlab
run_dss(f_out, f_mask, f_dwi, f_fmri, tau, alpha, neigh)
```

This function takes coregistered fMRI and DWI data from a subject, as well as a white matter mask, generates diffusion ODFs from the DWI data, creates a white matter graph, and smooths the fMRI data in a diffusion-informed way using graph filtering. The smoothed fMRI volume series is saved and can be used in standard fMRI analysis pipelienes that do not include further spatial smoothing. If possible, the function reuses previously-generated diffusion ODFs and white matter graphs.

The smoothing has three parameters:
- `tau` controls the spatial size of the filters.
- `alpha` controls the degree of directional encoding in the filters. The default is 0.9.
- `neigh` controls the size of the neighborhood definition for each vertex in the graph. The default value is 5.

e.g.
```matlab
run_dss('data/filtered.nii', 'data/mask.nii', 'data/dwi.nii.gz', 'data/fmri.nii', 4)

run_dss('data/filtered.nii', 'data/mask.nii', 'data/dwi.nii.gz', 'data/fmri.nii', 4, 0.85, 3)
```

For details on the method, usage, and parameters, please refer to the aforementioned paper and the documentation for individual functions.
