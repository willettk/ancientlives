function plot_consensus_chars( filename, fragment_identifier, is_visible, consensus_chars, peaks, expert_chars, expert_x, expert_y, y_offset )
%
% Plot the consensus characters and, if available, the expert characters.
% The plot is printed to a pdf file whose filename contains the
% fragment_identifier. The is_visible flag determines if the plot is also 
% displayed. 
%
% Since the MATLAB plot command doesn't display unicode, but can 
% handle latex strings, we call map_greek_characters_to_latex to map the
% Greek characters to latex strings that can be displayed. Many but not all
% of the Greek characters can be displayed in this way. 
%
% plot_consensus_chars( filename, fragment_identifier, is_visible, consenus_chars, peaks, expert_chars, expert_x, expert_y, y_offset )

% Set up variables to differentiate between the case, expert vs. no expert,
% and the case of a displayed vs. non-displayed plot. We also set the
% offset of the expert location so that the expert and consensus characters
% do not overlap. 
if nargin < 9
    y_offset = 10;
end
if nargin == 5
    expert_chars = [];
    expert_x = [];
    expert_y = [];
end

if ~is_visible
    figure( 'Visible', 'off' ); 
else 
    figure( 'Visible', 'on' ); 

end

% Plot the consensus characters
cc = [ consensus_chars{:} ];
k = ~( cc == ' ' );
cc = cc( k );
if ~isempty( cc )
    x = peaks( k, 1 );
    y = peaks( k, 2 );
    plot( x, y, '+w' );
    latex = map_greek_characters_to_latex( cc );
    text( x, y, latex, 'fontname', 'Lucinda Console', 'fontsize', 10 );
end

% Plot the expert characters, if available
if ~isempty( expert_chars )
    hold on;
    plot( expert_x, expert_y, '+w' );
    latex = map_greek_characters_to_latex( [ expert_chars{:} ] );
    text( expert_x, expert_y + y_offset, latex, 'fontname', 'Lucinda Console', 'fontsize', 10, 'color', 'red' );
    hold off;
end

% Add title, the axes labels, and set up name for plot file
if ~isempty( expert_chars )
    title_str = sprintf( 'Consensus Characters vs. Expert Characters for Fragment: %d', fragment_identifier );
else
    title_str = sprintf( 'Consensus Characters for Fragment: %d', fragment_identifier );
end
title( title_str, 'fontsize', 18 );
xlabel( 'x', 'fontsize', 16 );
ylabel( 'y', 'fontsize', 16 );
axis ij; % Flip the orientation of the figure so it displays correctly. 
axis equal;

%  write figure to file
print( gcf, '-dpdf', filename ); %#ok<MCPRT>
if ~ is_visible 
    delete( gcf );
end




