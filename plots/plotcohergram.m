function varargout = plotcohergram( C, t, f, plt )
% PLOTCPECGRAM spectrogram plot with options.
%
% Usage:
% varargout = plotcohergram( C, t, f, plt )
%
% Inputs:
% C: input vector as a function of time and frequency (t x f)
% t (optional): t axis grid for plot. Default 1:size(C,1)
% f (optional): f axis grid for plot. Default 1:size(C,2)
% plt: "linear" for linear coherence. "tan" for hyperbolic arctangent 
% coherence, "flog" for logarithmic logarithmic frequency, "logtan" for
% logarithmic frequency and arctan coherence. Default: "tan".
% 
% Output:
% hAx (optional): Axes handle.
% 
% Example:
% fs = 100;              % Sampling frequency (Hz)
% t = 0 : 1/fs : 5;        % Time vector (0 to 10 seconds)
% f1 = 10;              % Frequency for the first 5 secs (Hz)
% f2 = 25;              % Frequency for the last 5 seconds (Hz)
% y1 = zeros( size( t ) );   % Initialize the signal
% y1( t < 2.5 ) = sin( 2 * pi * f1 * t( t < 2.5 ) ); 
% y1(t >= 2.5 ) = sin( 2 * pi * f2 * t( t >= 2.5 ) );
% y2 = zeros( size( t ) );
% y2(t >= 2.5 ) = sin( 2 * pi * f2 * t( t >= 2.5 ) );
% params = struct( 'tapers', [ 3 5 ], 'Fs', fs );
% win = [ 0.5 0.05 ];
% [ C, S12, S1, S2, t, f ] = cohgramc( y1, y2, win, params );
% subplot( 2, 1, 1 )
% plot( t, y )
% subplot( 2, 1, 2 )
% plotcohergram( C, tC, f, "tan" )


if nargin < 1
    error( 'Need data' )

end

[ NT, NF ] = size( C );
if nargin < 2
    t = 1 : NT;

end

if nargin < 3
    f = 1 : NF;

end

if length( f ) ~= NF || length( t ) ~= NT
    error( 'Axes grid and data have incompatible lengths' );

end

if nargin < 4 || isempty( plt )
    plt = "tan";

end

plt = string( plt );
switch plt
    case "linear"
        imagesc( t, f, C' )
        axis xy

    case "tan"
        imagesc( t, f, atanh( C' ) )
        axis xy

    case { "flog", "logtan" }
        varInfo = whos( 'C' );
        byteSize = varInfo.bytes;
        
        % pcolor doesn't deal well with large data. decimate as needed.
        % lesser than 10 MB decimate by 2.
        if byteSize < 10e6 
            t = t( 1 : 2 : end );
            C = C( 1 : 2 : end, : );
        
        % greater than 10 MB decimate by 6.
        elseif byteSize >= 10e6 && byteSize < 100e6 
            t = t( 1 : 6 : end );
            C = C( 1 : 6 : end, : );
        
        % greater than 100 MB decimate by 10.
        elseif byteSize >= 100e6 
            t = t( 1 : 10 : end );
            C = C( 1 : 10 : end, : );

        end
        
        % choose flog or tanlog.
        if strcmp( plt, "flog" )
            pcolor( t, f, C' )
            shading flat
            set( gca, "Yscale", "log" )

        elseif strcmp( plt, "logtan" )
            pcolor( t, f, atanh( C' ) )
            shading flat
            set( gca, "Yscale", "log" )

        end

end

if nargout > 0
    varargout{ 1 } = gca;

end
hold off



