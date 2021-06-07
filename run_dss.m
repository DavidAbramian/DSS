function run_dss(f_out, f_mask, f_dwi, f_fmri, tau, alpha, neigh)
%RUN_DSS - Perform diffusion-informed spatial smoothing of fMRI data
%Main function in DSS package. This function generates ODFs from DWI data
%using the DSI Studio software. Using these, it creates a white matter
%graph that encodes at every point the local orientation of the underlying
%axonal fibers. Finally, it performs graph heat kernel filtering on an fMRI
%volume series and saves the filtered volume series. The ODFs and generated
%graphs are saved for reuse.
%
% Syntax:  run_dss(f_out,f_mask,f_dwi,f_fmri,alpha,tau,neigh)
%
% Inputs:
%    f_out - Path of output filtered fMRI volume series. Data will be
%      stored in an uncompressed NIfTI file.
%    f_mask - Path of uncompressed NIfTI volume containing binary white
%      matter mask.
%    f_dwi - Path of NIfTI volume series containing DWI data (can be
%      compressed).
%    f_fmri - Description
%    tau - Size parameter for filter kernel. Larger values result in larger
%      filters. Takes real non-negative values.
%    alpha - Soft threshold for graph weights. Higher values result in more
%      anisotropic filters. Takes values in [0,1] (default: 0.9).
%    neigh - Size of neighborhood shell defining the set of neighbors for
%      each vertex. Takes values in {3,5} (default: 5).
%
% Example:
%    run_dss('data/filtered.nii', 'data/mask.nii', 'data/dwi.nii.gz', ...
%      'data/fmri.nii', 4)
%    run_dss('data/filtered.nii', 'data/mask.nii', 'data/dwi.nii.gz', ...
%      'data/fmri.nii', 4, 0.85, 3)
%
% See also: DSS_CREATE_GRAPH,  DSS_FILTER_FMRI

% Author: David Abramian
% Department of Biomedical Engineering, Linköping University, Sweden
% email: david.abramian@liu.se
% May 2021; Last revision: 13-May-2021

% check input
assert(nargin == 7, 'Expected 7 arguments.')
assert(endsWith(f_mask, '.nii', 'IgnoreCase', true), ...
    'Expected .nii file\n%s', f_mask)
assert(endsWith(f_dwi, [".nii", ".nii.gz"], 'IgnoreCase', true), ...
    'Expected .nii or .nii.gz file\n%s', f_dwi)
assert(endsWith(f_fmri, '.nii', 'IgnoreCase', true), ...
    'Expected .nii file\n%s', f_fmri)
assert(exist(f_mask,'file')==2, 'File does not exist\n%s', f_mask)
assert(exist(f_dwi,'file')==2, 'File does not exist\n%s', f_dwi)
assert(exist(f_fmri,'file')==2, 'File does not exist\n%s', f_fmri)

f_path = fileparts(f_dwi);
f_graph = fullfile(f_path, ['graph_a', num2str(100*alpha, '%.0f'), '_n', num2str(neigh), '.mat']);

if ~exist(f_graph, 'file')
    f_odfs = fullfile(f_path, 'odfs.mat');
    if ~exist(f_odfs, 'file')
        % generate ODFs
        f_odfs = generate_odfs(f_dwi, f_mask);
    end
    
    % create white matter graph
    G = dss_create_graph(f_odfs, f_mask, alpha, neigh);
else
    % load existing white matter graph
    load(f_graph, 'G')
end

% perform graph filtering
dss_filter_fmri(f_out, f_fmri, f_mask, G, tau);

