function get_statistics( fragment_ids, user_ids, chars, frag_filename, stat_filename )
%
% GET_STATISTICS  - Prints the statistics on a set of fragments to file
% 
% get_statistics( fragment_ids, user_ids, chars, frag_filename, stat_filename );

fid = fopen( stat_filename, 'w', 'n', 'utf-8');
fprintf( fid, 'Statistics for %s\n\n', frag_filename );

% First get the characters and their distribution
[ unique_chars , ~, char_labels ] = unique( chars );
char_counts = histc( char_labels, 1 : max( char_labels ) );
[ ~, perm ] = sort( char_counts, 'descend' );
fprintf( fid, 'Characters counts\n' );
num_unique_chars = length( unique_chars );
for i = 1 : num_unique_chars
    unicodestr = native2unicode( unique_chars{ perm( i ) }, 'utf-8');
    fprintf( fid, '%s %d\n', unicodestr, char_counts( perm( i ) ) );
end
fprintf( fid, '\n\n' );

% Get the list of unique fragments
[ unique_fragment_ids , ~, fragment_labels ] = unique( fragment_ids );
char_count_per_fragment = histc( fragment_labels, 1 : max( fragment_labels ) );
num_unique_fragments = length( unique_fragment_ids );
num_users_per_fragment = zeros( num_unique_fragments, 1 );
fprintf( fid, 'Fragment info on %d fragments\n', num_unique_fragments );
fprintf( fid, 'Fragment id \t num users \t num characters\n' );
for i = 1 : num_unique_fragments
    k = fragment_ids == unique_fragment_ids( i );
    frag_user_ids = user_ids( k );
    [ frag_unique_user_ids ] = unique( frag_user_ids );  
    num_users_per_fragment( i ) = length( frag_unique_user_ids );
end

[ sorted_values perm ] = sortrows( [ num_users_per_fragment char_count_per_fragment ], [ -1 -2 ] );

for i = 1 : num_unique_fragments
    fprintf( fid, '%d \t \t %d \t \t %d\n', unique_fragment_ids( perm( i ) ),  sorted_values( i, 1 ), sorted_values( i, 2 ) );
end
fprintf( fid, '\n\n' );

% Get the list of unique users
[ unique_user_ids , ~, user_id_labels ] = unique( user_ids );
char_count_per_user = histc( user_id_labels, 1 : max( user_id_labels ) );
num_unique_users = length( unique_user_ids );
num_frags_per_user = zeros( num_unique_users, 1 );
fprintf( fid, 'user info on %d users\n', num_unique_users );
fprintf( fid, 'User id \t num frags \t num characters\n' );
for i = 1 : num_unique_users
    k = user_ids == unique_user_ids( i );
    user_frag_ids = fragment_ids( k );
    [ user_unique_frag_ids ] = unique( user_frag_ids );  
    num_frags_per_user( i ) = length( user_unique_frag_ids );
end

[ sorted_values perm ] = sortrows( [ num_frags_per_user char_count_per_user ], [ -1 -2 ] );

for i = 1 : num_unique_users
    fprintf( fid, '%d \t \t %d \t \t %d\n', unique_user_ids( perm( i ) ),  sorted_values( i, 1 ), sorted_values( i, 2 ) );
end

fclose( fid );



