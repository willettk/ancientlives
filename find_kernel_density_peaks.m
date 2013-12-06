function [ peaks peak_heights perm ] = find_kernel_density_peaks( data, h, bin_size )
%
% FIND_KERNEL_DENSITY_PEAKS - Find density based peaks in 2D data
%
% This routine finds the kernel density peak locations and heights of a set
% of 2D points using kernel density estimation. Optimization is used to
% find the peaks in the kernel density. 
%
% Input Variables: 
%   data    - 2D input data 
%   h       - kernel width
%   bin_size - size of bin
%
% Ouput Variables
%   peaks        - locations of the density peaks
%   peak_heights - height of the peaks
%
% [ peaks peak_heights perm ] = find_kernel_density_peaks( data, h, bin_size );


num_points = size( data, 1 );

% Bin the data for efficiency. Only neighboring eight bins of a bin are
% used to compute the density. 
[ data bins unique_bins bin_counts neighbors neighborhood_counts bin_beg bin_end bin_labels perm ] = get_bin_info( data, bin_size ); %#ok<ASGLU>
num_bins = size( unique_bins, 1 );

% Define output variables 
peaks = zeros( num_points, 2 );
peak_heights = zeros( num_points, 1 );
global fvalues;  % From density info helper function

% Bin tolerance
eps = 1e-6;  

% Find the peak associated with each point by processing each bin and its
% neighboring bins. 
cur_point = 1;
for i = 1 : num_bins
    
    % Find all (up to) 9 bins, the focus bin and its neighbors
    nine_bins = [ bin_labels( i ); nonzeros( neighbors( i, : ) ) ];
    neighbor_bin_points = zeros( neighborhood_counts( i ), 2 );
    num_neighbor_bin_points = 0;
    for j = 1 : length( nine_bins )
        cur_bin = nine_bins( j );
        num_points = bin_end( cur_bin ) - bin_beg( cur_bin ) + 1;
        neighbor_bin_points( num_neighbor_bin_points + 1 : num_neighbor_bin_points + num_points, : )  = ...
            data( bin_beg( cur_bin ) : bin_end( cur_bin ), : );
        num_neighbor_bin_points = num_neighbor_bin_points + num_points;
        if cur_bin == i  % Focus bin
            focus_bin_points = data( bin_beg( cur_bin ) : bin_end( cur_bin, : ), : );
            num_focus_bin_points = num_points;
        end
    end
    
    % Set up bin bounds for optimization to make sure the peak is not
    % outside the nine bin region 
    lb = (min( unique_bins( nine_bins, : ), [], 1 ) - 1) * bin_size - bin_size * eps;
    ub =  max( unique_bins( nine_bins, : ), [], 1 ) * bin_size      + bin_size * eps;
    bin_lb = repmat( lb, num_focus_bin_points, 1 ); 
    bin_ub = repmat( ub, num_focus_bin_points, 1 ); 
    bin_lb = bin_lb'; 
    bin_lb = bin_lb( : );
    bin_ub = bin_ub';
    bin_ub = bin_ub( : ); 
    
    % Call MATLAB's fmincon routine to find peaks in the density for all the 
    % points in the focus bin. The points in the 9 bin region contribute 
    % to the kernel density. 
    x0 = focus_bin_points'; 
    x0 = x0(:);  % fmincon expects a single point 
    options = optimset('tolfun',1e-20,'tolx',1e-10,'largescale','on','gradobj', ...
                       'on','Display','off', 'Hessian', 'on');
    temp_peaks = ...
        fmincon(@(focus_bin_points)density_info( focus_bin_points, neighbor_bin_points, h ), ...
                                  x0,[], [], [], [], bin_lb, bin_ub, [], options);

    % Put the results in the results variables and prepare for the next iteration
    peak_heights( cur_point : cur_point + num_focus_bin_points - 1  ) = -fvalues;
    temp_peaks = reshape( temp_peaks, 2, length( temp_peaks ) / 2 );
    temp_peaks = temp_peaks';
    peaks( cur_point : cur_point + num_focus_bin_points - 1,:) = temp_peaks;
    cur_point = cur_point + num_focus_bin_points;
    
    
end

% DENSITY_INFO does the actual work of finding the density peaks. 
% It is called by the MATLAB optimization function fmincon, and  
% and computes the function value, gradient, and hessian for use
% by fmincon. 
%
function [ f, g, hes ] = density_info( focus_bin_points, neighbor_bin_points, h )
%
% Set up and initialize variables 
x = reshape( focus_bin_points, 2, length( focus_bin_points ) / 2 );
x = x';
num_focus_bin_points = size( x, 1 );
global fvalues;
fvalues = zeros( num_focus_bin_points, 1 );
g = zeros( 2 * num_focus_bin_points, 1 );
hes = zeros( 2 * num_focus_bin_points, 2 * num_focus_bin_points );

cur_x1 = neighbor_bin_points( :, 1 );
cur_x2 = neighbor_bin_points( :, 2 );
for i = 1 : num_focus_bin_points
    
    % Compute f
    d_arg1 = x( i, 1 ) - cur_x1;
    d_arg2 = x( i, 2 ) - cur_x2;
    f_arg = exp( ( -h^2 * d_arg1.^2 - h^2 * d_arg2.^2 )/ ( 2 * h^4 ) );
    f = - sum( f_arg );
    fvalues( i ) = f;
    index = 2 * i - 1;
    g( index      ) = 1 / h^2 * sum( d_arg1 .* f_arg );
    g( index + 1  ) = 1 / h^2 * sum( d_arg2 .* f_arg );

    hes( index, index ) =         1 * sum(  ( 1/h^2 - d_arg1.^2/h^4 ) .* f_arg );
    hes( index + 1, index + 1 ) = 1 * sum(  ( 1/h^2 - d_arg2.^2/h^4 ) .* f_arg );
    hes( index, index + 1 ) =    -1 * sum( (d_arg1 .* d_arg2)/h^4 .* f_arg );
    hes( index + 1, index ) = hes( index, index + 1 );
end
f = sum( fvalues );


