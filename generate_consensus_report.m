function summary = generate_consensus_report( filename, consensus_results, comparison_results )
%
% Generate a report of the consensus characters and their locations. If the
% comparison results are specified, a report comparing the users to 
% the expert is produced. This routine generates reports as described in
% plan_to_use_experts_transcription.docx. 
%
% summary = generate_consensus_report( filename, consensus_results, comparison_results );

% Determine whether to output an xlsx or a text file
[ pathstr, name, ext] = fileparts( filename ); 
if strcmpi( ext, '.xlsx' ) 
    is_text = false;
else 
    is_text = true;
end

% Determine if comparison results are present
if nargin == 3
    if is_text 
        expert_to_user_comparison_file = fullfile( pathstr, [ strcat( name, '_expert_comparison' ), '.txt' ] );
    end
    num_non_matched_expert_locations = comparison_results.num_expert_chars ...
                                     - comparison_results.num_overlapping_locations_consensus;
else
    comparison_results = [];
    num_non_matched_expert_locations = 0;
    summary = '';
end
    
% Define some output variables for consensus report
num_consensus = length( consensus_results.consensus );
num_reporting_locations = num_consensus + num_non_matched_expert_locations;
cluster_labels = zeros( num_reporting_locations, 1 );
consensus_char = cell( num_reporting_locations, 1 );
expert_char = cell( num_reporting_locations, 1 );
total = zeros( num_reporting_locations, 1 );
conf = cell( num_reporting_locations, 1 );
x = cell( num_reporting_locations, 1 );
y = cell( num_reporting_locations, 1 );
distribution = cell( num_reporting_locations, 1 );

% First handle the consensus location part of consensus report 
for i = 1 : num_consensus
    cluster_labels( i ) = i;
    consensus_char( i ) = consensus_results.consensus( i );
    total( i ) = consensus_results.number_of_users( i );
     
    % Accumlate string results for the results file
    x{ i } =  sprintf( '%6.1f', consensus_results.x( i ) );
    y{ i } =  sprintf( '%6.1f', consensus_results.y( i ) );
    conf{ i } =  sprintf( '%4.2f', consensus_results.conf( i ) );
    
    % Make a string out of the distribution results
    cluster_chars = consensus_results.cluster_chars{ i };
    cluster_char_counts = consensus_results.cluster_char_counts{ i };
    num_chars = length( cluster_char_counts );
    s = '';
    for j = 1 : num_chars 
        if is_text
            unicodestr = native2unicode( cluster_chars{ j }, 'utf-8' );
            ss = sprintf( '%s(%d)', unicodestr, cluster_char_counts( j ) );
        else
            ss = sprintf( '%s(%d)', cluster_chars{ j }, cluster_char_counts{ j } );
        end
        s = strcat( s, ss );
    end
    distribution{ i } = s;
    
    % Add expert char info, if expert is present
    if ~ isempty( comparison_results )
        associated_expert_location = comparison_results.c2x_mapping( i );
        if associated_expert_location == 0
            expert_char{ i } = ' ';
        else
            expert_char{ i } = comparison_results.expert_chars( associated_expert_location ); 
        end
    end

end

% Now add any unmatched expert locations for consensus report
if ~ isempty( comparison_results )
    unmatched_locations = find( comparison_results.x2c_mapping == 0 );
    for i = 1 : num_non_matched_expert_locations
        ii = num_consensus + i; 
        cluster_labels( ii ) = ii;
        consensus_char{ ii }  = ' ';
        total( i ) = 0;

        % Accumlate string results for the results file
        current_expert_char_loc = unmatched_locations( i );
        x{ ii } =  sprintf( '%6.1f', comparison_results.x( current_expert_char_loc ) );
        y{ ii } =  sprintf( '%6.1f', comparison_results.y( current_expert_char_loc ) );
        conf{ ii } =  ' ';
        distribution{ ii } = ' ';

        % Add expert char info, if expert is present
        expert_char{ ii } = comparison_results.expert_chars( current_expert_char_loc ); 
    end
end
    
% If expert is present, add comparison report details
if ~ isempty( comparison_results )
    unique_user_ids = comparison_results.unique_user_ids;
    num_user_ids = length( unique_user_ids );
    
    str_frac_coverage_consensus = sprintf( '%05.2f', comparison_results.frac_coverage_consensus * 100 );
    str_frac_match_consensus = sprintf( '%05.2f', comparison_results.frac_match_consensus * 100 );

    % Declare some variables to hold output results per user
    frac_coverage_str = cell( num_user_ids, 1 );
    frac_match_str = cell( num_user_ids, 1 );
    num_expert_chars = zeros( length( num_user_ids ), 1 );
    num_expert_chars( 1 : end ) = comparison_results.num_expert_chars;

    % Loop over all users
    for i = 1 : num_user_ids
        frac_coverage_str{ i } = sprintf( '%05.2f', ...
                                          comparison_results.frac_coverage_user( i ) * 100 );
        frac_match_str{ i } = sprintf( '%05.2f', ...
                                        comparison_results.frac_match_user( i ) * 100 );
    end
end

% Determine which type of output file to write
if isempty( comparison_results )
    if is_text 
        % Write the text file when no expert 
        fp = fopen( filename, 'w', 'n', 'UTF-8' );
        fprintf( fp, 'label\t x\t y\t consensus\t distribution\t num clicks\t %% conf \n' );
        for i = 1 : length( x )
            unicodestr = native2unicode(consensus_char{i}, 'utf-8');
            s = sprintf( '%d\t %s\t %s\t %s\t %s\t %d\t %s ', ...
                         cluster_labels( i ), x{i}, y{i}, unicodestr, distribution{ i }, total(i), conf{i} );
            fprintf( fp, '%s\n', s );
        end
        fclose( fp );    
    else
        % Write the excel file when no expert 
        xls_header = { 'label','x', 'y','consensus', 'distribution', 'num clicks', '% conf' };
        xlswrite( filename, xls_header, 'Sheet1', 'A1' );

        xlswrite( filename, cluster_labels, 'Sheet1', 'A2' );
        xlswrite( filename, x, 'Sheet1', 'B2' );
        xlswrite( filename, y, 'Sheet1', 'C2' );
        xlswrite( filename, consensus_char, 'Sheet1', 'D2' );
        xlswrite( filename, distribution, 'Sheet1', 'E2' );
        xlswrite( filename, total, 'Sheet1', 'F2' );
        xlswrite( filename, conf, 'Sheet1', 'G2' );
    end
else
    if is_text
        % Write the consensus report text file when expert is present
        fp = fopen( filename, 'w', 'n', 'UTF-8' );
        fprintf( fp, 'label\t x\t y\t expert\t consensus\t distribution\t num clicks\t %% conf \n' );
        for i = 1 : length( x )
            unicodestr = native2unicode( consensus_char{i}, 'utf-8');
            unicodestr2 = native2unicode( expert_char{i}, 'utf-8');
            s = sprintf( '%d\t %s\t %s\t %s\t %s\t %s\t %d\t %s ', ...
                         cluster_labels( i ), x{i}, y{i}, unicodestr2, unicodestr, distribution{ i }, total(i), conf{i} );
            fprintf( fp, '%s\n', s );
        end
        fclose( fp );    
        
        % Write the comparison report text file 
        fp = fopen( expert_to_user_comparison_file, 'w', 'n', 'UTF-8' );
        fprintf( fp, 'user_id\t num expert\t num user\t num overlap\t num match\t %% overlap\t %% match \n' );
        
        % Print the summary line
        s = sprintf( '%d\t %d\t %d\t %d\t %d\t %s\t %s', 0, ...
                     comparison_results.num_expert_chars, ...
                     comparison_results.num_consensus_chars, ... 
                     comparison_results.num_overlapping_locations_consensus, ... 
                     comparison_results.num_matching_consensus_chars, ...
                     str_frac_coverage_consensus, ... 
                     str_frac_match_consensus ...
                     );
        fprintf( fp, '%s\n', s );
        summary = s;

        % Write the individual comparisions
        for i = 1 : length( unique_user_ids )
            s = sprintf( '%d\t %d\t %d\t %d\t %d\t %s\t %s', ...
                         unique_user_ids( i ), ... 
                         comparison_results.num_expert_chars, ...
                         comparison_results.num_user_chars( i ), ... 
                         comparison_results.num_overlapping_locations_user( i ), ...
                         comparison_results.num_matching_user_chars( i ), ... 
                         frac_coverage_str{ i }, ...
                         frac_match_str{ i } ...
                         );
            fprintf( fp, '%s\n', s );
        end
        fclose( fp );    
    else
        % Write the consensus report excel file when expert is present 
        summary = '';
        xls_header = { 'label','x', 'y', 'expert', 'consensus', 'distribution', 'num clicks', '% conf' };
        xlswrite( filename, xls_header, 'Sheet1', 'A1' );

        xlswrite( filename, cluster_labels, 'Sheet1', 'A2' );
        xlswrite( filename, x, 'Sheet1', 'B2' );
        xlswrite( filename, y, 'Sheet1', 'C2' );
        xlswrite( filename, expert_char, 'Sheet1', 'D2' );
        xlswrite( filename, consensus_char, 'Sheet1', 'E2' );
        xlswrite( filename, distribution, 'Sheet1', 'F2' );
        xlswrite( filename, total, 'Sheet1', 'G2' );
        xlswrite( filename, conf, 'Sheet1', 'H2' );
        
        % Write the comparison report excel file 
        xls_header2 = { 'user_id', 'num expert', 'num user', 'num overlap', 'num match', '% overlap', '% match' };
        xlswrite( filename, xls_header2, 'Sheet2', 'A1' );
        xlswrite( filename, 0, 'Sheet2', 'A2' );
        xlswrite( filename, comparison_results.num_expert_chars, 'Sheet2', 'B2' );
        xlswrite( filename, comparison_results.num_consensus_chars, 'Sheet2', 'C2' );
        xlswrite( filename, comparison_results.num_overlapping_locations_consensus, 'Sheet2', 'D2' );
        xlswrite( filename, comparison_results.num_matching_consensus_chars, 'Sheet2', 'E2' );
        xlswrite( filename, str_frac_coverage_consensus, 'Sheet2', 'F2' );
        xlswrite( filename, str_frac_match_consensus, 'Sheet2', 'G2' );
        
        xlswrite( filename, unique_user_ids, 'Sheet2', 'A3' );
        xlswrite( filename, num_expert_chars, 'Sheet2', 'B3' );
        xlswrite( filename, comparison_results.num_user_chars, 'Sheet2', 'C3' );
        xlswrite( filename, comparison_results.num_overlapping_locations_user, 'Sheet2', 'D3');
        xlswrite( filename, comparison_results.num_matching_locations_user, 'Sheet2', 'E3');
        xlswrite( filename, frac_coverage_str, 'Sheet2', 'F3');
        xlswrite( filename, frac_match_str, 'Sheet2', 'G3' );
        
    end
end
