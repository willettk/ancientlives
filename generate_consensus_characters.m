function consensus_results = generate_consensus_characters( peaks, peak_labels, chars )
%
% Generate the consensus characters and their locations. 
%
% consensus_results = generate_consensus_characters( peaks, peak_labels, chars );
    
% Define some output variables 
num_peaks = max( peak_labels );
consensus_chars = cell( num_peaks, 1 );
conf = zeros( num_peaks, 1 );
num_consensus_chars = zeros( num_peaks, 1 );
cluster_chars = cell( num_peaks, 1 );
cluster_char_counts = cell( num_peaks, 1 );

% For each peak, determine the consensus (majority) character and other info. 
for i = 1 : num_peaks
    % Get all the points and associated characters for the peak
    k = peak_labels == i;
    
    % Find the unique set of chars, and count, and then 
    % reorder according to most frequent character
    cluster_chars{ i } = chars( k );
    [ unique_cluster_chars , ~, labels ] = unique( cluster_chars{ i } );
    counts = histc( labels, 1 : max( labels ) );
    [ counts sort_perm ] = sort( counts, 'descend' );
    unique_cluster_chars = unique_cluster_chars( sort_perm );
    cluster_chars{ i } = unique_cluster_chars;
    cluster_char_counts{ i } = counts;
    
    % Calculate a few summary results
    num_consensus_chars( i ) = sum( counts );
    conf( i ) = counts( 1 ) / num_consensus_chars( i );
    consensus_chars( i ) =  unique_cluster_chars( 1 );
    
end

% Create the results structure
consensus_results = struct( ...
    'labels', { ( 1 : num_peaks )' }, ...
    'x', { peaks( :, 1 ) }, ...
    'y', { peaks( :, 2 ) }, ...
    'consensus', { consensus_chars }, ...
    'number_of_users', { num_consensus_chars }, ...
    'cluster_chars', { cluster_chars }, ...
    'cluster_char_counts', { cluster_char_counts }, ...
    'conf', { conf } ...
    );

