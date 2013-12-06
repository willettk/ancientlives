function comparison_results = compare_expert_to_consensus( ...
                                consensus_results, ...
                                peak_labels, ... 
                                user_ids, ...
                                x, y, chars, ... 
                                xx, xy, xchars, ...
                                expert_id )
%, 
% COMPARE_EXPERT_TO_CONSENSUS - Compare experts to the consensus and
%                               individual users
%
%
% comparison_results = compare_expert_to_consensus( ...
%                         consensus_results, ...
%                         peak_labels, ...
%                         user_ids, ...
%                         x, y, chars, ... 
%                         xx, xy, xchars, ...
%                         expert_id );
% 

consensus_chars = consensus_results.consensus;
cx = consensus_results.x;
cy = consensus_results.y;

% Determine the distance of each user to its consensus character and the max
dist_to_peak = sqrt( sum(( [ cx( peak_labels ) cy( peak_labels ) ] - [ x y ] ).^2 ) );
max_dist = max( dist_to_peak );

% Match the expert locations to consensus locations
[ x2c_mapping c2x_mapping ] = match_expert_and_consensus_locations( cx, cy, xx, xy, max_dist );

% Analyze the difference between the expert and user chars
% First do the overall statistics

% Find locations where there is a match and calculate statistics
num_consensus_chars = length( consensus_chars );
num_expert_chars = length( xchars );
matching_locations = x2c_mapping ~= 0;
num_overlapping_locations_consensus = sum( matching_locations );
xc = [ xchars{ : } ];
cc = [ consensus_chars{ : } ];
if num_overlapping_locations_consensus > 0
    matching_chars = xc( matching_locations ) == cc( x2c_mapping( matching_locations ) );
    num_matching_consensus_chars = sum( matching_chars );
else 
    num_matching_consensus_chars = 0;
end
frac_coverage_consensus = num_overlapping_locations_consensus / num_expert_chars;
frac_match_consensus = num_matching_consensus_chars / max( 1, num_overlapping_locations_consensus );

% Next compute statistics for each user

% First, find the list of unique users and initialize variables
[ unique_user_ids, ~, user_id_labels ] = unique( user_ids );
num_user_ids = max( user_id_labels );
num_user_chars = zeros( num_user_ids, 1 );
num_matching_user_chars = zeros( num_user_ids, 1 );
num_overlapping_locations_user = zeros( num_user_ids, 1 );
frac_coverage_user = zeros( num_user_ids, 1 );
frac_match_user = zeros( num_user_ids, 1 );

% Loop over all users
for i = 1 : num_user_ids
    % Find the users characters and locations.
    k = user_ids == unique_user_ids( i );
    num_user_chars( i ) = sum( k );
    user_chars = chars( k );
    uc = [ user_chars{ : } ];
    ux = x( k );
    uy = y( k );
    % Map them to the expert
    [ x2u_mapping, ~ ] = match_expert_and_consensus_locations( ux, uy, xx, xy, max_dist );
    matching_locations = x2u_mapping ~= 0;
    num_overlapping_locations_user( i ) = sum( matching_locations );
    if num_overlapping_locations_user( i ) > 0
        matching_chars = xc( matching_locations ) == uc( x2u_mapping( matching_locations ) );
        num_matching_user_chars( i ) = sum( matching_chars );
    else 
        num_matching_user_chars( i ) = 0;
    end
    frac_coverage_user( i ) = num_overlapping_locations_user( i ) / num_expert_chars;
    frac_match_user( i ) = num_matching_user_chars( i ) / max( 1, num_overlapping_locations_user( i ) );
end

comparison_results = struct(  ...
    'x2c_mapping', { x2c_mapping }, ...
    'c2x_mapping', { c2x_mapping }, ...
    'expert_chars', { xc }, ...
    'x', { xx }, ...
    'y', { xy }, ...
    'num_consensus_chars', num_consensus_chars, ...
    'num_expert_chars', num_expert_chars, ...
    'num_overlapping_locations_consensus', num_overlapping_locations_consensus, ...
    'num_matching_consensus_chars', num_matching_consensus_chars, ...
    'frac_coverage_consensus', frac_coverage_consensus, ...
    'frac_match_consensus', frac_match_consensus, ...
    'num_user_chars', { num_user_chars }, ...
    'num_overlapping_locations_user', { num_overlapping_locations_user }, ...
    'num_matching_user_chars', { num_matching_user_chars }, ...
    'frac_coverage_user', { frac_coverage_user }, ...
    'frac_match_user', { frac_match_user }, ...
    'unique_user_ids', { unique_user_ids }, ...
    'expert_id', expert_id ...
    );
                               
