function [ latex ] = map_greek_characters_to_latex( chars )
%
% MAP_GREEK_CHARACTERS_TO_LATEX - Map Greek characters to latex for easy plotting
%
% This routine uses a mapping defined in the greek_to_latex.mat. Not all
% characters are mapped. Non-mappable characters are displayed as a dot.
%
% [ latex ] = map_greek_characters_to_latex( chars );

load greek_to_latex.mat 
[ unique_chars , ~, char_labels ] = unique( chars );
if isempty( chars )
    return;
end
[ have_match match_index ] = ismember( unique_chars, greek_chars );
if sum( ~ have_match ) > 0
    error('map characters to Greek failed');
end
latex = latex_mapping( match_index( char_labels ) ); 