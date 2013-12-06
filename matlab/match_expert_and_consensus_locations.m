function [ x2c_mapping c2x_mapping ] = match_expert_and_consensus_locations( cx, cy, xx, xy, threshold )
%, 
% MATCH_EXPERT_AND_CONSENSUS_LOCATIONS - Create a mapping between expert 
%                                        and consensus locations 
%
%
% [ x2c_mapping c2x_mapping ] = match_expert_and_consensus_locations( cx, cy, xx, xy, threshold );

% Sort according to user and then computer the nearest neighbor and
% distance matrices. 

% Compute distance between the consensus characters and the expert chars 
d = pdist2( [ xx xy ], [ cx cy ] );

% The closest consensus char for each expert and vice-versa
[ xnn_dist, xnn_list ] = sort( d, 2 );
x2c_mapping = xnn_list( :, 1 );
[ cnn_dist, cnn_list ] = sort( d', 2 ); %#ok<UDIM>
c2x_mapping = cnn_list( :, 1 );

% Zero out list entries that are not reciprocal nearest neighbors or within
% the threshold
for i = 1 : length( x2c_mapping )
    if c2x_mapping( x2c_mapping( i ) ) ~= i || xnn_dist( i, 1 ) > threshold
        x2c_mapping( i ) = 0;
    end
end
for i = 1 : length( c2x_mapping )
    if x2c_mapping( c2x_mapping( i, 1 ) ) ~= i || cnn_dist( i, 1 ) > threshold
        c2x_mapping( i ) = 0;
    end
end






