function [ data, tEpochs ] = createdatamatc( data, E, Fs, win, t )
% Helper function to create an event triggered matrix from univariate
% continuous data
% Usage: data = createdatamatc( data, E, Fs, win)
% Inputs:
% data   (input time series as a column vector) - required
% E      (events to use as triggers) - required
% Fs     (sampling frequency of data) - required
% win    (window around triggers to use data matrix -[winl winr]) - required
%          e.g [1 1] uses a window starting 1 * Fs samples before E and
%              ending 1*Fs samples after E.
% Note that E, Fs, and win must have consistent units
%
% Outputs:
% data      (event triggered data)
%
if nargin < 4
    error( 'Need all the first four arguments' );
    
end

if nargin == 5
    tFlag = true;
    
else
    tFlag = false;
    
end

% Set up variables needed.
NE = length( E );
nwinl = round( win( 1 ) * Fs );
nwinr = round( win( 2 ) * Fs );
datatmp = [ ];
    
if tFlag == false
    [ m, n ] = size( data );
    nE = floor( E * Fs ) + 1;
    
    if n == 1
        for i = 1 : NE
            indx = nE( i ) - nwinl : nE( i ) + nwinr - 1;
            lnIndx = length( indx );
            
            % Catch if a time window extends beyond the signal start or
            % end.
            if indx( 1 ) < 0
                tmp = data( 1 : indx( end ) );
                datatmp( 1 : lnIndx, i ) = nan;
                datatmp( lnIndx - length( tmp ) + 1 : lnIndx, i ) = tmp;
                warning( [ 'Event %i''s window was truncated because ',...
                    'it started before data.'], i )
                
            elseif length( data ) < indx( end )
                tmp = data( indx( 1 ) : end );
                datatmp( 1 : lnIndx, i ) = nan;
                tmpLength = length( indx( 1 ) : length( data ) );
                datatmp( 1 : tmpLength, i ) = tmp;
                warning( [ 'Event %i''s window was truncated because ',...
                    'it ended after data.' ], i ) 
                
            else
                datatmp( :, i ) = data( indx );
            
            end
            
        end
        data = datatmp;
        
    else
        for i = 1 : NE
            indx = nE( i ) - nwinl : nE( i ) + nwinr - 1;
            lnIndx = length( indx );
            
            % Catch if a time window extends beyond the signal start or
            % end.
            if indx( 1 ) < 0
                tmp = data( 1 : indx( end ), : );
                datatmp( 1 : lnIndx, 1 : n, i ) = nan;
                datatmp( lnIndx - length( tmp ) + 1 : lnIndx, 1 : n, i ) = tmp;
                warning( [ 'Event %i''s window was truncated because ',...
                    'it started before data.'], i )
            
            elseif length( data ) < indx( end )            
                tmp = data( indx( 1 ) : end, : );
                datatmp( 1 : lnIndx, 1 : n, i ) = nan;
                tmpLength = length( indx( 1 ) : length( data ) );
                datatmp( 1 : tmpLength, 1 : n, i ) = tmp;
                warning( [ 'Event %i''s window was truncated because ',...
                    'it ended after data.' ], i ) 
                
            else
                datatmp( :, :, i ) = data( indx, : );
            
            end
            
        end
            
        data = datatmp;
        
    end
    
else
    tol = max( diff( t ) ) + eps;
    tTmp = [];
    
    for i = 1 : NE
        lfpIdx = find( t > E( i ) & t < E( i ) + tol );
        indx = lfpIdx - nwinl : lfpIdx + nwinr - 1;
        datatmp = [ datatmp data( indx ) ];
        tTmp = [ tTmp t( indx ) ];
        
    end
    data = datatmp;
    tEpochs = tTmp;
    
end