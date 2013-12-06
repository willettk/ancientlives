function [ peaks, peak_heights peak_labels perm ] = filter_kde_results( peaks, peak_heights, binsize, peak_merge_threshold )
%
% FILTER_RESULTS Filter results to eliminate duplicate peaks
%
% This routine merges nearby peaks to eliminate duplicates. Peaks are 
% binned for efficiency. 
%
% [ peaks, peak_heights peak_labels perm ] = filter_kde_results( peaks,
% peak_heights, binsize, peak_merge_threshold );
%

% Bin the results
% [ ~, data unique_bins , ~, ~, neighbors bin_beg bin_end bin_labels perm ] = get_bin_info( peaks,binsize );
[ data, ~, unique_bins, ~, neighbors , ~, bin_beg bin_end, bin_labels, perm ] = get_bin_info( peaks,binsize );
% Rearrange the input data to match the binned data
peaks = peaks( perm, : );
peak_heights = peak_heights( perm );

% Set some variables
n = size( unique_bins, 1 );
bin_has_been_processed = false( n, 1 ); 
keep_point =  true( size( data, 1 ), 1 );

% Process the remaining bins
for i = 1 : n
    if bin_has_been_processed( i )
        continue;
    end
    
    % Find data in bin neighborhood
    nine_bins = [ bin_labels( i ); nonzeros( neighbors( i, : ) )];
    nine_bin_data = [];
    point_locs = [];
    for j = 1 : length( nine_bins )
        cur_bin = nine_bins( j );
        if bin_has_been_processed( cur_bin )
            continue;
        end
        indices = ( bin_beg( cur_bin ) : bin_end( cur_bin ) )';
        indices = indices( keep_point( indices ) );
        nine_bin_data = [ nine_bin_data; data( indices, : ) ]; %#ok<AGROW>
        point_locs = [ point_locs; indices ];  %#ok<AGROW>
        if j == 1
            bin_data = nine_bin_data;
            num_bin_points = size( bin_data, 1 );
        end
    end
    
    % Compute the distances of the point being processed to other points and
    % filter if necessary
    for j = 1 : num_bin_points
        if ~ keep_point( point_locs( j ) )
            continue;
        end
        dups = abs( bin_data( j, 1 ) - nine_bin_data( :, 1 ) ) <  peak_merge_threshold & ...
               abs( bin_data( j, 2 ) - nine_bin_data( :, 2 ) ) <  peak_merge_threshold;
        dups( j ) = false; 
        dups = dups & keep_point( point_locs );
        if sum( dups ) == 0 
            continue;
        end
        locs = point_locs( dups );
        ph = peak_heights( point_locs( j ) );
        pk = peaks( point_locs( j ), : );
        ph_of_dups = peak_heights( locs );
        pk_of_dups = peaks( locs, : );
        points_to_be_eliminated = ph_of_dups <= ph;
        locs = locs( points_to_be_eliminated );
        if sum( ~ points_to_be_eliminated ) > 0 
            keep_point(  point_locs( j ) ) = false;
            [ max_ph jj ] = max( ph_of_dups );
            peak_heights( point_locs( j ) ) = max_ph;
            peaks( point_locs( j ), : ) = pk_of_dups( jj, : );
        else
            keep_point( locs ) = false;
            peak_heights( locs ) = ph;
            peaks( locs, 1 ) = pk( 1 );
            peaks( locs, 2 ) = pk( 2 );
        end
    end
    bin_has_been_processed( i ) = true;  
end

% Assign labels to the unique peaks and thus to the points
[ peaks selected peak_labels ] = unique( peaks, 'rows' );
peak_heights = peak_heights( selected );

