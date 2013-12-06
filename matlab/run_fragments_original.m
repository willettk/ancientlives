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


warning('off','all');
load fraglist.txt;
frags_to_run = fraglist;
num_frags_to_run = length( frags_to_run );


% load the database
load ../20130708_db2.mat


%num_frags_to_run=3;



for i = 1 : num_frags_to_run
    k = fragment_ids == frags_to_run( i );
    frag_user_ids = user_ids( k );
    frag_x = x( k );
    frag_y = y( k );
    frag_chars = chars( k );
    disp( frags_to_run( i ) );
    for h = [ 8 6 5 3 ]
        binsize = 2 * h;
        peak_merge_threshold = h;
        [ frag_x frag_y peaks peak_heights peak_labels frag_chars frag_user_ids ] = run_kde( h, binsize, peak_merge_threshold, frag_x, frag_y, frag_chars, frag_user_ids );
        consensus_filename = sprintf( 'fragment_%d_consensus_%d.txt', frags_to_run( i ), h );
        consensus_results = generate_consensus_characters( peaks, peak_labels, frag_chars );
        generate_consensus_report( consensus_filename, consensus_results );

    % Plot the consensus characters 
    is_visible = false;
    plot_filename = sprintf( 'fragment_%d_plot_%d.pdf', frags_to_run( i ), h );
    plot_consensus_chars( plot_filename, frags_to_run( i ), is_visible, ...
                          consensus_results.consensus, peaks );
    end
end
%fclose( fp );
