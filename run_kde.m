function [ x y peaks peak_heights peak_labels chars user_ids ] = run_kde( h, bin_size, peak_merge_threshold, x, y, chars, user_ids )
% 
% RUN_KDE  Find the kernel density peak locations in a set of 2D points
%
% This routine finds peaks in kernel density, filters them to eliminate
% duplicates, and then returns the peaks associated with each point.
%
% Since data is being reshuffled for efficiency, it is necessary to keep
% track of efficiency. Also note that peaks from find_kernel_density_peaks
% is the same size of the data, but after filtering duplicates are
% eliminated and the connection of data points to labels is made by
% peak_labels. 
% 
% [ x y peaks peak_heights peak_labels chars user_ids ] = run_kde( h, bin_size, peak_merge_threshold, x, y, chars, user_ids );

data = [ x, y ];


% Find the peak locations and values in the 2D density
%   Note that the list of peaks contains the closest peak for each
%   click and thus, will likely contain duplicates. 

[ peaks peak_heights perm ] = find_kernel_density_peaks( data, h, bin_size );
     
% Filter the peaks to get unique peaks and group clicks into clusters 
% associated with their closest peak
[ peaks peak_heights peak_labels new_perm ] = ...
    filter_kde_results( peaks, peak_heights, bin_size, peak_merge_threshold );

perm = perm( new_perm );

% Rearrange the original data and extract some key fields
x = x( perm );
y = y( perm );
user_ids = user_ids( perm );
chars = chars( perm );


