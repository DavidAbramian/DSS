function process_odfs(f_odfs)
%PROCESS_ODFS Clean up ODF data generated by DSI Studio.
%Removes unused variables from DSI Studio output and refactors remaining
%variables.
%
% Syntax:  process_odfs(f_odfs)
%
% Inputs:
%    f_odfs - Path of MAT file containing diffusion ODFs generated with DSI
%      Studio
%
% Examples:
%    A = process_odfs('data/odfs.mat')

% Author: David Abramian
% Department of Biomedical Engineering, Linköping University, Sweden
% email: david.abramian@liu.se
% May 2021; Last revision: 13-May-2021


% check input
assert(endsWith(f_odfs, '.mat', 'IgnoreCase', true), ...
    'Expected .mat file\n%s', f_odfs)
assert(exist(f_odfs,'file')==2, 'File does not exist\n%s', f_odfs)

% load only necessary variables
load(f_odfs, 'dimension', 'fa*', 'odf*', 'odf_faces', 'odf_vertices', 'voxel_size')

% combine and rename ODF variables
ml_catvars('odf',2);
odfs = odf;

% find index of voxels having ODFs
I_odfs = find(fa0');

% save only useful variables
save(f_odfs, 'dimension', 'I_odfs', 'odfs', 'odf_faces', 'odf_vertices', 'voxel_size')

end

