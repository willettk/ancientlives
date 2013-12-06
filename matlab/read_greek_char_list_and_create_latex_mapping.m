function [ headers greek_chars latex_mapping char_description ] = read_greek_char_list_and_create_latex_mapping( filename )
%
% READ_GREEK_CHARACTER_LIST_AND_CREATE_LATEX_MAPPING  
%
% Read in a list of Greek characters and their mapping to latex characters.
% This is used for display since MATLAB has problems displaying Unicode 
% characters. This routine also uses strtok instead of textscan because
% textscan does not currently support Unicode. Actually, it seems to read
% the Unicode character, but the character is 'messed up' in some way.
%
% [ headers greek_chars latex_mapping char_description ] = read_greek_char_list_and_create_latex_mapping( filename );

% Open the file and read the headers.
% Header line is assume to look like this "char,mapping,description"
fid = fopen( filename, 'r', 'n', 'utf-8');
line = fgetl( fid );
headers = textscan( line, '%q','whitespace', ' \b\t,');
headers = headers{ 1 };
headers = lower( strtrim( headers ) )';

% Windows puts in an extra character at the start of the file for UTF-8. If
% so, remove it before checking headers for correctness.  
if headers{ 1 }( 1 ) ~= 'c';  
    headers{ 1 } = headers{ 1 }( 2 : end );
end

if ~strcmpi( headers{ 1 }, 'char' ) || ~strcmpi( headers{ 2 }, 'mapping' ) || ...
   ~strcmpi( headers{ 3 }, 'description' ) 
   error( 'Wrong file format' );
end

% Read the lines, one by one 
max_lines = 100;
greek_chars = cell( 1, max_lines );
latex_mapping = cell( 1, max_lines );
char_description = cell( 1, max_lines );
num_lines = 0;
while ~feof( fid )
    line = fgetl( fid );
    num_lines = num_lines + 1;
    [ greek_chars{ num_lines } rest_of_line ] = strtok( line );
    [ latex_mapping{ num_lines } rest_of_line ] = strtok( rest_of_line ); %#ok<*STTOK>
    [ char_description{ num_lines } ] = strtok( rest_of_line  );
end

greek_chars = greek_chars( 1 : num_lines );
greek_chars = [ greek_chars{:} ];
latex_mapping = latex_mapping( 1 : num_lines );
char_description = char_description( 1 : num_lines );
save greek_to_latex.mat greek_chars latex_mapping char_description;

