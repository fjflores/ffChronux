function plotcrossings( t, mask, minLength, yValue, color )
% PLOTCROSSINGS Plots horizontal lines for threshold-crossing segments.
%
% Usage:
% plot_crossing_lines(t, mask, min_length, y_value, color)
%
% Inputs:
% t: Time vector (same length as mask)
% mask:  Logical vector indicating where the signal crosses the threshold
% min_length: Minimum number of consecutive points to count as a valid crossing
% y_value: Y-coordinate at which the horizontal line should be drawn
% color: RGB vector specifying the color of the line (e.g., [1 0 0] for red)
%
% This function identifies sequences of `min_length` or more consecutive `true`
% values in `mask`, and for each sequence, draws a horizontal line at `y_value`
% from the start time to the end time of the sequence.
%
% Example usage:
% plot_crossing_lines(t, data > threshold, 3, 3, [1 0 0]);

d = diff( [ 0 mask 0 ] );
start_idx = find(d == 1);
end_idx = find(d == -1) - 1;

for i = 1 : length( start_idx )

    if end_idx( i ) - start_idx( i ) + 1 >= minLength
        tStart = t( start_idx( i ) );
        tEnd = t( end_idx( i ) );
        plot( [ tStart tEnd ], [ yValue yValue ], ...
            'Color', color, 'LineWidth', 4 );

    end

end
