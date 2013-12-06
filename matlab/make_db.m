% Run KDE code on a set of fragments

% Variables used in this test script:  
%     ( x, y ) - the location of the characters (user and expert)
%     chars - character at that location
%     peaks - unique set of locations of the consensus characters
%     peak_heights - intensity of the density peak of a consensus location 
%     peak_labels  - maps the characters to their corresponding peaks 
%     user_ids - user ids of all who transcribed the fragment
%     consensus_chars - list of consensus characters (locations are peaks)
%     is_visible - true if plot is to be displayed, as well as printed to a file

% Read information for users
[ ~, fragment_ids, user_ids, x, y, chars ] = read_fragments_mod('markers.txt');

save markers_db2.mat fragment_ids user_ids x y chars;


exit;
