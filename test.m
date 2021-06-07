
root = '/Users/davab27/Work/DSS/data/';
f_out = fullfile(root, 'out.nii');
f_mask = fullfile(root, 'mask.nii');
f_dwi  = fullfile(root, 'data.nii.gz');
f_fmri = fullfile(root, 'fmri.nii');
alpha = .9;
tau = 4;
neigh = 5;

run_dss(f_out, f_mask, f_dwi, f_fmri, tau, alpha, neigh)