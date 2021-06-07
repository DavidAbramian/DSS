function dss_filter_fmri(f_out, f_fmri, f_mask, G, tau)
%DSS_FILTER_FMRI Perform graph filtering on fMRI volume series.
%Smooth fMRI volume series using graph heat kernel filtering.
%
% Syntax:  dss_filter_fmri(f_fmri,f_mask,G,tau)
%
% Inputs:
%    f_out - Path of output filtered fMRI volume series. Data will be
%      stored in an uncompressed NIfTI file.
%    f_fmri - Path of uncompressed NIfTI volume series containing fMRI
%      data to filter.
%    f_mask - Path of uncompressed NIfTI volume containing binary white
%      matter mask.
%    G - White matter graph structure.
%    tau - Size parameter for filter kernel. Larger values result in larger
%      filters. Takes real non-negative values.
%
% Examples:
%    graph_filter_fmri('data/filtered.nii', data/fmri.nii', ...
%      'data/mask.nii', G, 4)
%
% See also: DSS_CREATE_GRAPH, GRAPH_FILTERING

% Author: David Abramian, adapted from Martin Larsson, 2017
% Department of Biomedical Engineering, Linköping University, Sweden
% email: david.abramian@liu.se
% May 2021; Last revision: 13-May-2021


% check input
assert(endsWith(f_fmri, '.nii', 'IgnoreCase', true), ...
    'Expected .nii file\n%s', f_fmri)
assert(endsWith(f_mask, '.nii', 'IgnoreCase', true), ...
    'Expected .nii file\n%s', f_mask)
assert(exist(f_fmri,'file')==2, 'File does not exist\n%s', f_fmri)
assert(exist(f_mask,'file')==2, 'File does not exist\n%s', f_mask)
assert(all(isfield(G, ["L","l_max"])), 'Missing fields in graph structure')
assert(tau >= 0, 'tau must be a non-negative scalar')

% load white matter mask
[~, mask] = ml_load_nifti(f_mask);
dim = size(mask);
I_mask = find(mask);

% construct heat kernel filter
% kernel = cell(length(tau), 1);
% for i = 1:length(tau)
%     kernel{i} = @(x) exp(-x*tau(i));
% end
kernel = @(x) exp(-x*tau);
cheb_ord = 15;

% load volume headers
headers = ml_load_nifti(f_fmri);
n_vols = length(headers);

% load fMRI volumes
signals = zeros(length(I_mask), n_vols);
for i = 1:n_vols
    progresss(i, n_vols, 'Loading fMRI volumes... ')
    
    [h, vol] = ml_load_nifti(f_fmri, i);
    signals(:,i) = vol(I_mask);
end
progresss(i+1, n_vols, 'Loading fMRI volumes... ')

% perform graph heat kernel filtering
fprintf('Performing graph filtering\n')
coeff = graph_filtering(G.L, G.l_max, kernel, signals, cheb_ord);

% save filtered volumes
for i = 1:n_vols
    progresss(i, n_vols, 'Saving filtered volumes... ')
    
    vol_out = nan(dim);
    vol_out(I_mask) = coeff(:,i);
    
    h.fname = f_out;
    h.n(1) = i;
    spm_write_vol(h, vol_out);
end
progresss(i+1, n_vols, 'Saving filtered volumes... ')


end

