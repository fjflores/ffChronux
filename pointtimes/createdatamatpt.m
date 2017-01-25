function data = createdatamatpt( data, E, win, rel )
% Helper function to create an event triggered matrix from a single
% channel of spike times. 
% Usage:  data=createdatamatpt(data,E,win)
% Inputs:
% data   (input spike times as a structural array or as a column vector) - required
% E      (events to use as triggers) - required 
% win    (window around triggers to use data matrix -[winl winr]) - required 
%          e.g [1 1] uses a window starting 1 sec before E and
%              ending 1 sec after E if E and data are in secs.
% Note that E, win and data must have consistent units
% Outputs:
% data      (event triggered data as a structural array. If rel = true, 
%           times are stored relative to E - win(1).

if nargin < 3; 
    error('Need all input arguments');
    
elseif nargin < 4
    rel = true;
    
end;

if isstruct(data);
   fnames = fieldnames( data );
   eval( [ 'dtmp = data.' fnames{ 1 } ';' ] )
   
else
   dtmp = data( : );
   
end;

NE = length( E );
winl = win( 1 );
winr = win( 2 );
data2( 1 : NE ) = struct( 'times', [ ] );

for n = 1 : NE,
    indx = find( dtmp > E( n ) - winl & dtmp <= E( n ) + winr );
    if ~isempty( indx )
        if rel
            data2( n ).times = dtmp( indx ) - E( n ) + winl;
            
        else
            data2( n ).times = dtmp( indx );
            
        end
       
    else
       data2( n ).times = [ ];
       
    end
    
end
data = data2;