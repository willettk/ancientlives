function [ headers fragment_ids, user_ids, x, y, chars ] = read_fragments_mod( filename, has_headers )
%
% READ_FRAGMENTS  Read Greek fragment data in UTF-8 format
%
% Reads a UTF-8 text file containing one or more Greek fragments. We assume
% no header unless specified.   
%
% [ headers fragment_ids, user_ids, x, y, chars ] = read_fragments( filename, has_headers );

% Open the file and read the headers
% File is assumed to have these fields: id, user_id, fragment_id, x, y,character
fid = fopen( filename, 'r', 'n', 'utf-8');

headers = { 'user_id', 'fragment_id', 'x','y','character'};



% Read the lines, one by one keeping only user_id, fragment_id, x, y, and character
max_lines = 10000000;
user_ids = zeros( max_lines, 1 );
fragment_ids = zeros( max_lines, 1 );
x = zeros( max_lines, 1 );
y = zeros( max_lines, 1 );
chars = cell( max_lines, 1 );
num_lines = 0;
while ~feof( fid )
    num_lines = num_lines + 1;
    if mod( num_lines, 20000 ) == 0 
        disp( num_lines );
    end
    line = fgetl( fid );
    [t, count, error_msg, nextindex]  = sscanf( line,'%d,', 4 );
    if count ~= 4
        error( 'Error reading %s at line %d: %s\n %s\n', filename, num_lines, line, error_msg );
    end
    user_ids( num_lines ) = t( 1 );
    fragment_ids( num_lines ) = t( 2 );
    x( num_lines ) = t( 3 );
    y( num_lines ) = t( 4 );
    % chars{ num_lines } = line( nextindex ); % JW original
    chars{ num_lines } = strrep(line( nextindex :length(line)),'"','');     % KW modification
end

user_ids = user_ids( 1 : num_lines );
fragment_ids = fragment_ids( 1 : num_lines );
x = x( 1 : num_lines );
y = y( 1 : num_lines );
chars = chars( 1 : num_lines );

