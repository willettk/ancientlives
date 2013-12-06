function [ data bins unique_bins bin_counts neighbors neighborhood_counts bin_beg bin_end bin_labels perm ] = get_bin_info( data, bin_size )
%
% BIN_INFO    Bin 2D data into 2D bins
% 
% This function bins 2D data into 2D bins using a user specified bin size 
% Note that for now, equal bins are used for both dimensions.
%
% In addition to binning, the code reorders the data for more efficient 
% access of all points in the bin. The 'perm' variable captures this 
% sort. The up to eight adjacent neighbors of each bin are also identified,
% again for more efficient access. 
%
% [ bins data unique_bins bin_counts neighborhood_counts neighbors ...
%   bin_beg bin_end bin_labels perm ] = get_bin_info( data, bin_size )

% Bin the data into 2D bins
num_data_points = size( data, 1 );
bins = ceil( [ ( data(:,1) / bin_size ) ( data(:,2) / bin_size ) ] );

% Sort the data and bins for quick access to points in a bin
bins_and_data = [ bins data ];
[ bins_and_data perm ] = sortrows( bins_and_data, [ 1 2 ] ); 
bins = bins_and_data( :, 1:2 );
data = bins_and_data( :, 3:4 );

% Find nonempty bins and the number of points in each bin
[ unique_bins , ~, bin_labels ] = unique( bins, 'rows' );
num_unique_bins = size( unique_bins, 1 );
unique_bin_labels = ( 1 : num_unique_bins )';
bin_counts = histc( bin_labels, unique_bin_labels );

% Find the beginning and end of each bin in the data matrix
if num_unique_bins > 1
    diff_labels = diff( bin_labels );
    k = find( diff_labels );
    bin_beg = [ 1; k + 1 ];
    bin_end = [ k; num_data_points ];
else
    bin_beg = [ 1; 1 ];
    bin_end = [ 1; num_data_points ];
end

% Find the up to 8 neighboring bins
i = unique_bins( :, 1 );
j = unique_bins( :, 2 );
neighbors = zeros( num_unique_bins, 8 );
neighborhood_counts = bin_counts;
if num_unique_bins > 1


    % Find a bin's neighbors with lower and higher j
    %   The following code does this by sorting.  
    temp = sortrows( [ i j unique_bin_labels ], [ 1 2 ] );
    I = temp( :, 1 );
    J = temp( :, 2 );
    label = temp( : , 3 );
    diff_I = diff( I );
    diff_J = diff( J );
    lowerj_neighbor_flag = [ false; diff_I == 0 & diff_J == 1 ];
    lowerj_neighbor = zeros( num_unique_bins, 1 );
    higherj_neighbor = zeros( num_unique_bins, 1 );
    indices = find( lowerj_neighbor_flag );
    lowerj_neighbor( indices ) = label( indices - 1 );  
    higherj_neighbor( indices - 1 ) = label( indices );
    k = find( lowerj_neighbor );
    neighbors( label( k ), 1 ) = lowerj_neighbor( k );
    neighborhood_counts( label( k ) ) = neighborhood_counts( label( k ) ) + bin_counts( lowerj_neighbor( k ) ); 
    k = find( higherj_neighbor );
    neighbors( label( k ), 2 ) = higherj_neighbor( k );
    neighborhood_counts( label( k ) ) = neighborhood_counts( label( k ) ) + bin_counts( higherj_neighbor( k ) ); 

    % Find a bin's neighbors with lower and higher i
    temp = sortrows( [ i j unique_bin_labels ], [ 2 1 ] );
    I = temp( :, 1 );
    J = temp( :, 2 );
    label = temp( : , 3 );
    diff_I = diff( I );
    diff_J = diff( J );
    loweri_neighbor_flag = [ false; diff_J == 0 & diff_I == 1 ];
    higheri_neighbor = zeros( num_unique_bins, 1 );
    loweri_neighbor = zeros( num_unique_bins, 1 );
    indices = find( loweri_neighbor_flag );
    loweri_neighbor( indices ) = label( indices - 1 );  
    higheri_neighbor( indices - 1 ) = label( indices );
    k = find( loweri_neighbor );
    neighbors( label( k ), 3 ) = loweri_neighbor( k );
    neighborhood_counts( label( k ) ) = neighborhood_counts( label( k ) ) + bin_counts( loweri_neighbor( k ) ); 
    k = find( higheri_neighbor );
    neighbors( label( k ), 4 ) = higheri_neighbor( k );
    neighborhood_counts( label( k ) ) = neighborhood_counts( label( k ) ) + bin_counts( higheri_neighbor( k ) ); 

    % Find a bin's neighbors with lower i and lower j or vice-versa
    temp = sortrows( [ i j unique_bin_labels i - j ], [ 4 1 ] );
    I = temp( :, 1 );
    J = temp( :, 2 );
    label = temp( : , 3 );
    diff_ij = temp( : , 4 );
    diff_I = diff( I );
    diff_J = diff( J );
    diff_diff_ij = diff( diff_ij );
    loweri_lowerj_neighbor_flag = [ false; diff_diff_ij == 0 & diff_I == 1 & diff_J == 1 ];
    loweri_lowerj_neighbor = zeros( num_unique_bins, 1 );
    higheri_higherj_neighbor = zeros( num_unique_bins, 1 );
    indices = find( loweri_lowerj_neighbor_flag );
    higheri_higherj_neighbor( indices ) = label( indices - 1 );  
    loweri_lowerj_neighbor( indices - 1 ) = label( indices );
    k = find( higheri_higherj_neighbor );
    neighbors( label( k ), 5 ) = higheri_higherj_neighbor( k );
    neighborhood_counts( label( k ) ) = neighborhood_counts( label( k ) ) + bin_counts( higheri_higherj_neighbor( k ) ); 
    k = find( loweri_lowerj_neighbor );
    neighbors( label( k ), 6 ) = loweri_lowerj_neighbor( k );
    neighborhood_counts( label( k ) ) = neighborhood_counts( label( k ) ) + bin_counts( loweri_lowerj_neighbor( k ) ); 

    % Find a bin's neighbors with higher i and lower j or vice-versa
    temp = sortrows( [ i j unique_bin_labels i + j ], [ 4 1 ] );
    I = temp( :, 1 );
    J = temp( :, 2 );
    label = temp( : , 3 );
    sum_ij = temp( : , 4 );
    diff_I = diff( I );
    diff_J = diff( J );
    diff_sum_ij = diff( sum_ij );
    higheri_lowerj_neighbor_flag = [ false; diff_sum_ij == 0 & diff_I == 1 & diff_J == -1 ];
    higheri_lowerj_neighbor = zeros( num_unique_bins, 1 );
    loweri_higherj_neighbor = zeros( num_unique_bins, 1 );
    indices = find( higheri_lowerj_neighbor_flag );
    higheri_lowerj_neighbor( indices ) = label( indices - 1 );  
    loweri_higherj_neighbor( indices - 1 ) = label( indices );
    k = find( higheri_lowerj_neighbor );
    neighbors( label( k ), 7 ) = higheri_lowerj_neighbor( k );
    neighborhood_counts( label( k ) ) = neighborhood_counts( label( k ) ) + bin_counts( higheri_lowerj_neighbor( k ) ); 
    k = find( loweri_higherj_neighbor );
    neighbors( label( k ), 8 ) = loweri_higherj_neighbor( k );
    neighborhood_counts( label( k ) ) = neighborhood_counts( label( k ) ) + bin_counts( loweri_higherj_neighbor( k ) ); 
end

bin_labels = unique_bin_labels;

